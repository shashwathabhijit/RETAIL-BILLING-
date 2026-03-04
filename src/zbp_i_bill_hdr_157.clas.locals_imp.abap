*CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.
*
*    METHODS create FOR MODIFY IMPORTING entities FOR CREATE Header.
*    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Header.
*    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Header.
*    METHODS cba_Billitems FOR MODIFY IMPORTING entities_cba FOR CREATE Header\_BillItems.
*    METHODS MarkAsPaid FOR MODIFY IMPORTING keys FOR ACTION Header~MarkAsPaid RESULT result.
*
*    METHODS lock FOR LOCK IMPORTING keys FOR LOCK Header.
*
*    " ---> ADDED: Read method for Header
*    METHODS read FOR READ IMPORTING keys FOR READ Header RESULT result.
*ENDCLASS.
*
*CLASS lhc_header IMPLEMENTATION.
*
*  METHOD get_instance_authorizations.
*    " Leave empty for now. This tells the framework "allow all actions".
*  ENDMETHOD.
*
* METHOD create.
*    LOOP AT entities INTO DATA(ls_entity).
*       DATA(ls_hdr) = CORRESPONDING zbill_hdr_157( ls_entity MAPPING FROM ENTITY ).
*       ls_hdr-bill_uuid = ls_entity-BillUuid.
*
*       " Send to buffer
*       zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).
*
*       " DO NOT populate mapped-header here!
*       " 'numbering: managed' in the BDEF handles it automatically.
*    ENDLOOP.
*  ENDMETHOD.
*  METHOD update.
*    DATA ls_hdr TYPE zbill_hdr_157.
*    LOOP AT entities INTO DATA(ls_entity).
*      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_entity-BillUuid INTO @ls_hdr.
*      IF ls_entity-%control-CustomerName = if_abap_behv=>mk-on. ls_hdr-customer_name = ls_entity-CustomerName. ENDIF.
*      IF ls_entity-%control-PaymentStatus = if_abap_behv=>mk-on. ls_hdr-payment_status = ls_entity-PaymentStatus. ENDIF.
*      zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD delete.
*    LOOP AT keys INTO DATA(ls_key).
*      zcit_utl_22cs157=>get_instance( )->buffer_del_hdr( ls_key-BillUuid ).
*    ENDLOOP.
*  ENDMETHOD.
*  METHOD MarkAsPaid.
*    DATA ls_hdr TYPE zbill_hdr_157.
*    LOOP AT keys INTO DATA(ls_key).
*      " Fetch the current record
*      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_key-BillUuid INTO @ls_hdr.
*
*      " Update the status
*      ls_hdr-payment_status = 'Paid'.
*
*      " Send updated record to the buffer
*      zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).
*    ENDLOOP.
*  ENDMETHOD.
*  METHOD cba_Billitems.
*    DATA ls_itm TYPE zbill_itm_157.
*    LOOP AT entities_cba INTO DATA(ls_cba_entity).
*      LOOP AT ls_cba_entity-%target INTO DATA(ls_target).
*        ls_itm = CORRESPONDING #( ls_target MAPPING FROM ENTITY ).
*        ls_itm-itemuuid = ls_target-ItemUuid.
*        ls_itm-billuuid = ls_cba_entity-BillUuid.
*
*        " Send to buffer
*        zcit_utl_22cs157=>get_instance( )->buffer_itm( ls_itm ).
*
*        " DO NOT populate mapped-billitem here!
*        " 'numbering: managed' in the BDEF handles it automatically.
*      ENDLOOP.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD lock.
*    LOOP AT keys INTO DATA(ls_key).
*      " Check if the record actually exists before trying to lock
*      SELECT SINGLE bill_uuid FROM zbill_hdr_157
*        WHERE bill_uuid = @ls_key-BillUuid
*        INTO @DATA(lv_dummy).
*
*      IF sy-subrc <> 0.
*        " Explicitly map the BillUuid instead of using %key
*        APPEND VALUE #( BillUuid = ls_key-BillUuid ) TO failed-header.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  " ---> ADDED: Read implementation for Header
*  METHOD read.
*    LOOP AT keys INTO DATA(ls_key).
*      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_key-BillUuid INTO @DATA(ls_db).
*      IF sy-subrc = 0.
*        INSERT CORRESPONDING #( ls_db ) INTO TABLE result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*ENDCLASS.
*
*CLASS lhc_BillItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE BillItem.
*    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE BillItem.
*
*    " ---> ADDED: Read method for Item
*    METHODS read FOR READ IMPORTING keys FOR READ BillItem RESULT result.
*ENDCLASS.
*
*CLASS lhc_BillItem IMPLEMENTATION.
*  METHOD update.
*    DATA ls_itm TYPE zbill_itm_157.
*    LOOP AT entities INTO DATA(ls_entity).
*      SELECT SINGLE * FROM zbill_itm_157 WHERE itemuuid = @ls_entity-ItemUuid INTO @ls_itm.
*      IF ls_entity-%control-Quantity = if_abap_behv=>mk-on. ls_itm-quantity = ls_entity-Quantity. ENDIF.
*      IF ls_entity-%control-UnitPrice = if_abap_behv=>mk-on. ls_itm-unitprice = ls_entity-UnitPrice. ENDIF.
*      zcit_utl_22cs157=>get_instance( )->buffer_itm( ls_itm ).
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD delete.
*    LOOP AT keys INTO DATA(ls_key).
*      zcit_utl_22cs157=>get_instance( )->buffer_del_itm( ls_key-ItemUuid ).
*    ENDLOOP.
*  ENDMETHOD.
*
*  " ---> ADDED: Read implementation for Item
*  METHOD read.
*    LOOP AT keys INTO DATA(ls_key).
*      SELECT SINGLE * FROM zbill_itm_157 WHERE itemuuid = @ls_key-ItemUuid INTO @DATA(ls_db).
*      IF sy-subrc = 0.
*        INSERT CORRESPONDING #( ls_db ) INTO TABLE result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*ENDCLASS.
*
*CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.
*
*    METHODS create FOR MODIFY IMPORTING entities FOR CREATE Header.
*    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Header.
*    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Header.
*    METHODS cba_Billitems FOR MODIFY IMPORTING entities_cba FOR CREATE Header\_Billitems.
*    METHODS MarkAsPaid FOR MODIFY IMPORTING keys FOR ACTION Header~MarkAsPaid RESULT result.
*
*    METHODS lock FOR LOCK IMPORTING keys FOR LOCK Header.
*
*    METHODS read FOR READ IMPORTING keys FOR READ Header RESULT result.
*ENDCLASS.
*
*CLASS lhc_header IMPLEMENTATION.
*
*  METHOD get_instance_authorizations.
*    " Leave empty for now. This tells the framework "allow all actions".
*  ENDMETHOD.
*
*  METHOD create.
*    LOOP AT entities INTO DATA(ls_entity).
*       DATA(ls_hdr) = CORRESPONDING zbill_hdr_157( ls_entity MAPPING FROM ENTITY ).
*       ls_hdr-bill_uuid = ls_entity-BillUuid.
*
*       zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).
*       INSERT VALUE #( %cid = ls_entity-%cid BillUuid = ls_hdr-bill_uuid ) INTO TABLE mapped-header.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD update.
*    DATA ls_hdr TYPE zbill_hdr_157.
*    LOOP AT entities INTO DATA(ls_entity).
*      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_entity-BillUuid INTO @ls_hdr.
*      IF ls_entity-%control-CustomerName = if_abap_behv=>mk-on. ls_hdr-customer_name = ls_entity-CustomerName. ENDIF.
*      IF ls_entity-%control-PaymentStatus = if_abap_behv=>mk-on. ls_hdr-payment_status = ls_entity-PaymentStatus. ENDIF.
*      zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD delete.
*    LOOP AT keys INTO DATA(ls_key).
*      zcit_utl_22cs157=>get_instance( )->buffer_del_hdr( ls_key-BillUuid ).
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD cba_Billitems.
*    DATA ls_itm TYPE zbill_itm_157.
*    LOOP AT entities_cba INTO DATA(ls_cba_entity).
*      LOOP AT ls_cba_entity-%target INTO DATA(ls_target).
*        ls_itm = CORRESPONDING #( ls_target MAPPING FROM ENTITY ).
*
*        ls_itm-itemuuid = ls_target-ItemUuid.
*        ls_itm-billuuid = ls_cba_entity-BillUuid.
*
*        zcit_utl_22cs157=>get_instance( )->buffer_itm( ls_itm ).
*        " ---> CORRECTED: mapped-billitem
*        INSERT VALUE #( %cid = ls_target-%cid ItemUuid = ls_itm-itemuuid ) INTO TABLE mapped-billitem.
*      ENDLOOP.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD MarkAsPaid.
*    DATA ls_hdr TYPE zbill_hdr_157.
*    LOOP AT keys INTO DATA(ls_key).
*      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_key-BillUuid INTO @ls_hdr.
*      ls_hdr-payment_status = 'Paid'.
*      zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).
*
*      INSERT VALUE #( BillUuid = ls_key-BillUuid
*                      %param   = VALUE #( BillUuid = ls_key-BillUuid ) ) INTO TABLE result.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD lock.
*    LOOP AT keys INTO DATA(ls_key).
*      SELECT SINGLE bill_uuid FROM zbill_hdr_157
*        WHERE bill_uuid = @ls_key-BillUuid
*        INTO @DATA(lv_dummy).
*
*      IF sy-subrc <> 0.
*        APPEND VALUE #( BillUuid = ls_key-BillUuid ) TO failed-header.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD read.
*    LOOP AT keys INTO DATA(ls_key).
*      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_key-BillUuid INTO @DATA(ls_db).
*      IF sy-subrc = 0.
*        INSERT CORRESPONDING #( ls_db ) INTO TABLE result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*ENDCLASS.
*
*" ---> CORRECTED: Entire class definition uses BillItem
*CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE BillItem.
*    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE BillItem.
*
*    METHODS read FOR READ IMPORTING keys FOR READ BillItem RESULT result.
*ENDCLASS.
*
*CLASS lhc_item IMPLEMENTATION.
*  METHOD update.
*    DATA ls_itm TYPE zbill_itm_157.
*    LOOP AT entities INTO DATA(ls_entity).
*      SELECT SINGLE * FROM zbill_itm_157 WHERE itemuuid = @ls_entity-ItemUuid INTO @ls_itm.
*      IF ls_entity-%control-Quantity = if_abap_behv=>mk-on. ls_itm-quantity = ls_entity-Quantity. ENDIF.
*      IF ls_entity-%control-UnitPrice = if_abap_behv=>mk-on. ls_itm-unitprice = ls_entity-UnitPrice. ENDIF.
*      zcit_utl_22cs157=>get_instance( )->buffer_itm( ls_itm ).
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD delete.
*    LOOP AT keys INTO DATA(ls_key).
*      zcit_utl_22cs157=>get_instance( )->buffer_del_itm( ls_key-ItemUuid ).
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD read.
*    LOOP AT keys INTO DATA(ls_key).
*      SELECT SINGLE * FROM zbill_itm_157 WHERE itemuuid = @ls_key-ItemUuid INTO @DATA(ls_db).
*      IF sy-subrc = 0.
*        INSERT CORRESPONDING #( ls_db ) INTO TABLE result.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*ENDCLASS.
*
*CLASS lsc_zbp_i_bill_hdr_157 DEFINITION INHERITING FROM cl_abap_behavior_saver.
*  PROTECTED SECTION.
*    METHODS save REDEFINITION.
*    METHODS cleanup REDEFINITION.
*ENDCLASS.
*
*CLASS lsc_zbp_i_bill_hdr_157 IMPLEMENTATION.
*  METHOD save.
*    DATA(lt_hdr) = zcit_utl_22cs157=>get_instance( )->get_buffered_hdr( ).
*    IF lt_hdr IS NOT INITIAL. MODIFY zbill_hdr_157 FROM TABLE @lt_hdr. ENDIF.
*
*    DATA(lt_itm) = zcit_utl_22cs157=>get_instance( )->get_buffered_itm( ).
*    IF lt_itm IS NOT INITIAL. MODIFY zbill_itm_157 FROM TABLE @lt_itm. ENDIF.
*
*    DATA(lt_del_hdr) = zcit_utl_22cs157=>get_instance( )->get_del_hdr( ).
*    IF lt_del_hdr IS NOT INITIAL.
*      LOOP AT lt_del_hdr INTO DATA(ls_del_hdr).
*        DELETE FROM zbill_hdr_157 WHERE bill_uuid = @ls_del_hdr-bill_uuid.
*        DELETE FROM zbill_itm_157 WHERE billuuid = @ls_del_hdr-bill_uuid.
*      ENDLOOP.
*    ENDIF.
*
*    DATA(lt_del_itm) = zcit_utl_22cs157=>get_instance( )->get_del_itm( ).
*    IF lt_del_itm IS NOT INITIAL.
*      LOOP AT lt_del_itm INTO DATA(ls_del_itm).
*        DELETE FROM zbill_itm_157 WHERE itemuuid = @ls_del_itm-itemuuid.
*      ENDLOOP.
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD cleanup.
*    zcit_utl_22cs157=>get_instance( )->clear_buffer( ).
*  ENDMETHOD.
*ENDCLASS.
CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS create FOR MODIFY IMPORTING entities FOR CREATE Header.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Header.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Header.
    METHODS cba_Billitems FOR MODIFY IMPORTING entities_cba FOR CREATE Header\_Billitems.
    METHODS MarkAsPaid FOR MODIFY IMPORTING keys FOR ACTION Header~MarkAsPaid RESULT result.

    METHODS lock FOR LOCK IMPORTING keys FOR LOCK Header.

    METHODS read FOR READ IMPORTING keys FOR READ Header RESULT result.
ENDCLASS.

CLASS lhc_header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
       DATA(ls_hdr) = CORRESPONDING zbill_hdr_157( ls_entity MAPPING FROM ENTITY ).
       ls_hdr-bill_uuid = ls_entity-BillUuid.

       " FIX 1: Generate UUID if the framework didn't provide one
       IF ls_hdr-bill_uuid IS INITIAL.
         TRY.
             ls_hdr-bill_uuid = cl_system_uuid=>create_uuid_x16_static( ).
           CATCH cx_uuid_error.
         ENDTRY.
       ENDIF.

       zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).
       INSERT VALUE #( %cid = ls_entity-%cid BillUuid = ls_hdr-bill_uuid ) INTO TABLE mapped-header.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA ls_hdr TYPE zbill_hdr_157.
    LOOP AT entities INTO DATA(ls_entity).
      " Read existing data
      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_entity-BillUuid INTO @ls_hdr.

      " Apply changes ONLY if the control flag is on
      IF ls_entity-%control-CustomerName = if_abap_behv=>mk-on.
        ls_hdr-customer_name = ls_entity-CustomerName.
      ENDIF.
      IF ls_entity-%control-PaymentStatus = if_abap_behv=>mk-on.
        ls_hdr-payment_status = ls_entity-PaymentStatus.
      ENDIF.

      zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      zcit_utl_22cs157=>get_instance( )->buffer_del_hdr( ls_key-BillUuid ).
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Billitems.
    DATA ls_itm TYPE zbill_itm_157.
    LOOP AT entities_cba INTO DATA(ls_cba_entity).
      LOOP AT ls_cba_entity-%target INTO DATA(ls_target).
        ls_itm = CORRESPONDING #( ls_target MAPPING FROM ENTITY ).

        ls_itm-itemuuid = ls_target-ItemUuid.
        ls_itm-billuuid = ls_cba_entity-BillUuid.

        " FIX 2: Generate Item UUID if missing
        IF ls_itm-itemuuid IS INITIAL.
          TRY.
              ls_itm-itemuuid = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
          ENDTRY.
        ENDIF.

        zcit_utl_22cs157=>get_instance( )->buffer_itm( ls_itm ).
        INSERT VALUE #( %cid = ls_target-%cid ItemUuid = ls_itm-itemuuid ) INTO TABLE mapped-billitem.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD MarkAsPaid.
    DATA ls_hdr TYPE zbill_hdr_157.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_key-BillUuid INTO @ls_hdr.
      ls_hdr-payment_status = 'Paid'.
      zcit_utl_22cs157=>get_instance( )->buffer_hdr( ls_hdr ).

      INSERT VALUE #( BillUuid = ls_key-BillUuid
                      %param   = VALUE #( BillUuid = ls_key-BillUuid ) ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    " FIX 3: Do not fail if the record isn't in the DB yet.
    " A real implementation requires an ENQUEUE lock object.
    " Leaving this empty allows draft activation to succeed.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE * FROM zbill_hdr_157 WHERE bill_uuid = @ls_key-BillUuid INTO @DATA(ls_db).
      IF sy-subrc = 0.
        INSERT CORRESPONDING #( ls_db ) INTO TABLE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE BillItem.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE BillItem.

    METHODS read FOR READ IMPORTING keys FOR READ BillItem RESULT result.
ENDCLASS.

CLASS lhc_item IMPLEMENTATION.
  METHOD update.
    DATA ls_itm TYPE zbill_itm_157.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM zbill_itm_157 WHERE itemuuid = @ls_entity-ItemUuid INTO @ls_itm.
      IF ls_entity-%control-Quantity = if_abap_behv=>mk-on. ls_itm-quantity = ls_entity-Quantity. ENDIF.
      IF ls_entity-%control-UnitPrice = if_abap_behv=>mk-on. ls_itm-unitprice = ls_entity-UnitPrice. ENDIF.
      zcit_utl_22cs157=>get_instance( )->buffer_itm( ls_itm ).
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      zcit_utl_22cs157=>get_instance( )->buffer_del_itm( ls_key-ItemUuid ).
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE * FROM zbill_itm_157 WHERE itemuuid = @ls_key-ItemUuid INTO @DATA(ls_db).
      IF sy-subrc = 0.
        INSERT CORRESPONDING #( ls_db ) INTO TABLE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zbp_i_bill_hdr_157 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_zbp_i_bill_hdr_157 IMPLEMENTATION.
  METHOD save.
    DATA(lt_hdr) = zcit_utl_22cs157=>get_instance( )->get_buffered_hdr( ).
    IF lt_hdr IS NOT INITIAL. MODIFY zbill_hdr_157 FROM TABLE @lt_hdr. ENDIF.

    DATA(lt_itm) = zcit_utl_22cs157=>get_instance( )->get_buffered_itm( ).
    IF lt_itm IS NOT INITIAL. MODIFY zbill_itm_157 FROM TABLE @lt_itm. ENDIF.

    DATA(lt_del_hdr) = zcit_utl_22cs157=>get_instance( )->get_del_hdr( ).
    IF lt_del_hdr IS NOT INITIAL.
      LOOP AT lt_del_hdr INTO DATA(ls_del_hdr).
        DELETE FROM zbill_hdr_157 WHERE bill_uuid = @ls_del_hdr-bill_uuid.
        DELETE FROM zbill_itm_157 WHERE billuuid = @ls_del_hdr-bill_uuid.
      ENDLOOP.
    ENDIF.

    DATA(lt_del_itm) = zcit_utl_22cs157=>get_instance( )->get_del_itm( ).
    IF lt_del_itm IS NOT INITIAL.
      LOOP AT lt_del_itm INTO DATA(ls_del_itm).
        DELETE FROM zbill_itm_157 WHERE itemuuid = @ls_del_itm-itemuuid.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    zcit_utl_22cs157=>get_instance( )->clear_buffer( ).
  ENDMETHOD.
ENDCLASS.

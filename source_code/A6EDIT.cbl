       identification division.
       program-id. A6EDIT.
       date-written. 07-07-2024.
       author. TALENT NYOTA.
      *Description: A6 Edit.
      *
       environment division.
       configuration section.
      *
       input-output section.
      *
       file-control.
      * input-file declaration
           select input-file
               assign to INFILE
               organization is sequential.

           select valid-file
               assign to VALID
               organization is sequential.

           select invalid-file
               assign to NOTVALID
               organization is sequential.
      *
      * output-file declaration
           select output-file
               assign to OUTFILE
               organization is sequential.
      *
       data division.
       file section.
      **********************************************
       fd input-file
           recording mode is F
           data record is input-line
           record contains 36 characters.
      *
       01 input-line.
           05 il-tran-code                  pic x.
                88 il-valid-tran-code
                    value 'S', 'R', 'L'.
           05 il-tran-amount                pic 9(5)V99.
           05 il-pay-type                   pic xx.
                88 il-valid-pay-type
                    value 'CA', 'CR', 'DB'.
           05 il-store-num                  pic 99.
                88 il-valid-store-num
                    value 01, 02, 03, 04, 05, 12.
           05 il-invoice-num.
      *First three invoice nums are alphabetic.
                10 il-invoice-num-1         pic x.
                    88 il-valid-invoice-num-1
                        value 'A', 'B', 'C', 'D', 'E'.
                10 il-invoice-num-2         pic x.
                    88 il-valid-invoice-num-2
                        value 'A', 'B', 'C', 'D', 'E'.
                10 il-invoice-num-3         pic x.
                    88 il-valid-invoice-num-3
                        value '-'.
                10 il-invoice-num-4-9       pic 9(6).
                    88 il-valid-invoice-num-4-9
                        value 100000 thru 900000.
           05 il-sku-code                   pic x(15).
                88 il-valid-sku-code
                    value spaces.
      ************************************************

       fd valid-file
           recording mode is F
           data record is valid-line
           record contains 36 characters.

       01 valid-line                        pic x(36).

      **********************************************

       fd invalid-file
           recording mode is F
           data record is invalid-line
           record contains 36 characters.

       01 invalid-line                      pic x(36).

      **********************************************

      *
       fd output-file
           recording mode is F
           data record is output-line
           record contains 175 characters.
      *
       01 output-line                       PIC X(175).

      **********************************************
       working-storage section.

       01 ws-eof-flag                       pic x
           value 'N'.
       01 ws-no-flag                        pic x
           value 'N'.
       01 ws-yes-flag                       pic x
           value 'Y'.
       01 ws-error-flag                     pic x
           value 'N'.


       01 ws-blank-line.
          05 filler                         pic x(175).

       01 ws-counters.
           05 ws-total-records              pic 999
                value 0.
           05 ws-valid-records              pic 999
                value 0.
           05 ws-invalid-records            pic 999
                value 0.
           05 ws-error-count                pic 999
                value 0.

       01 ws-headings-1.
           05 filler                        pic x(33)
                value "Error Report From Processing for ".
           05 ws-date-line                  pic 9(6).
           05 filler                        pic x(75)
                value spaces.
           05 ws-name-line                  pic x(17)
                value "Miguel Stoyke, A6".

       01 ws-headings-2.
           05 filler                        pic x(10)
                value "Input Data".
           05 filler                        pic x(29)
                value spaces.
           05 filler                        pic x(12)
                value "Tran. Code".
           05 filler                        pic x(1)
                value spaces.
           05 filler                        pic x(12)
                value "Tran. Amount".
           05 filler                        pic x(1)
                value spaces.
           05 filler                        pic x(8)
                value "Pay Type".
           05 filler                        pic x(1)
                value spaces.
           05 filler                        pic x(12)
                value "Store Number".
           05 filler                        pic x(1)
                value spaces.
           05 filler                        pic x(11)
                value "Inv. Number".
           05 filler                        pic x(1)
                value spaces.
           05 filler                        pic x(8)
                value "SKU Code".
           05 filler                        pic x(10)
                value spaces.
           05 filler                        pic x(15)
                value "Error Messages:".

       01 ws-headings-3.
           05 filler                        pic x(14)
                value "ERROR COUNT = ".
           05 ws-error-count-out            pic zz9.
           05 filler                        pic x(83)
                value spaces.

       01 ws-error-messages.
      *no err message for invoice number format as instructed

      *Transaction code must be S, L, or R
           05 ws-error-1-msg                pic x(24)
                value 'Invalid Transaction Code'.

      *Transaction Amount must be numeric
           05 ws-error-2-msg                pic x(26)
                value 'Invalid Transaction Amount'.

      *The Payment Type must be CA, CR or DB
           05 ws-error-3-msg                pic x(20)
                value 'Invalid Payment Type'.

      *The Store Number must be one of 01, 02, 03, 04, 05, 12
           05 ws-error-4-msg                pic x(20)
                value 'Invalid Store Number'.

      *The Invoice Number XX can only be A or B or C or D or E
           05 ws-error-5-msg                pic x(45)
                value 'Invalid Invoice Number - Out Of Letters Range'.

      *The Invoice Number XX cannot have two letters the same
           05 ws-error-6-msg                pic x(42)
                value 'Invalid Invoice Number - Duplicate Letters'.

      *Invoice Number Cannot be greater than 900000 or less than 100000
           05 ws-error-7-msg                pic x(45)
                value 'Invalid Invoice Number - Out Of Numbers Range'.

      *All records should have a dash - in position 3 of inv num
           05 ws-error-8-msg                pic x(35)
                value 'Missing Dash - In Pos. 3 of Inv Num'.

      *SKU Code with 15 characters cannot be empty
           05 ws-error-9-msg                pic x(24)
                value 'SKU Code cannot be empty'.

       01 ws-detail-line.
           05 ws-input-data-out             pic x(36).
           05 filler                        pic x(7)
                value spaces.
           05 ws-tran-code-out              pic x.
           05 filler                        pic x(8)
                value spaces.
           05 ws-tran-amount-out            pic Z(4)9.99.
           05 filler                        pic x(8)
                value spaces.
           05 ws-pay-type-out               pic xx.
           05 filler                        pic x(9)
                value spaces.
           05 ws-store-num-out              pic 99.
           05 filler                        pic x(6)
                value spaces.
           05 ws-invoice-num-out            pic x(12).
           05 ws-sku-out                    pic x(15).
           05 filler                        pic x(3)
                value spaces.
           05 ws-error-msg                  pic x(100).

      *
       procedure division.
       000-main.
           perform 100-openfiles.

           accept ws-date-line from date.
      *    accept ws-time-line from time.

           perform 200-writeheadings.
           perform 300-initialread.
           perform 400-processrecords
                until ws-eof-flag = ws-yes-flag.
           perform 500-printtotals.
           perform 600-closefiles.

           goback.

       100-openfiles.
           open input  input-file.
           open output output-file,
                       valid-file,
                       invalid-file.

       200-writeheadings.
           write output-line                from ws-headings-1.
           write output-line                from ws-blank-line.
           write output-line                from ws-headings-2.
           write output-line                from ws-blank-line.

       300-initialread.
           read input-file
                at end move ws-yes-flag     to ws-eof-flag.

       400-processrecords.
           add 1                            to ws-total-records.
           perform 420-editrecords.

           read input-file
                at end move ws-yes-flag     to ws-eof-flag.

       420-editrecords.
           move spaces                      to ws-error-msg.
           move ws-no-flag                  to ws-error-flag.

           if not il-valid-tran-code
                move ws-yes-flag            to ws-error-flag
                move ws-error-1-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

           if il-tran-amount is not numeric
                move ws-yes-flag            to ws-error-flag
                move ws-error-2-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

           if not il-valid-pay-type
                move ws-yes-flag            to ws-error-flag
                move ws-error-3-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

           if not il-valid-store-num
                move ws-yes-flag            to ws-error-flag
                move ws-error-4-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

           if not il-valid-invoice-num-1 or
              not il-valid-invoice-num-2
                move ws-yes-flag            to ws-error-flag
                move ws-error-5-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

           if il-invoice-num-1 = il-invoice-num-2
                move ws-yes-flag            to ws-error-flag
                move ws-error-6-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

           if il-invoice-num-4-9 is not numeric or
              not il-valid-invoice-num-4-9
                move ws-yes-flag            to ws-error-flag
                move ws-error-7-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

           if not il-valid-invoice-num-3
                move ws-yes-flag            to ws-error-flag
                move ws-error-8-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

           if il-sku-code = spaces
                move ws-yes-flag            to ws-error-flag
                move ws-error-9-msg         to ws-error-msg
                perform 440-writeerrors
           end-if.

       440-writeerrors.
      * Tried to get it to only print the input details 1 time if there
      * was an error. Could not get that to work, so it prints the full
      * detail line to show each error even for the same record if there
      * is more than 1.

      * Prints all errors that happened in the input-file with their
      * respective input data record.

           if ws-error-flag = ws-yes-flag
                add 1                       to ws-invalid-records
                add 1                       to ws-error-count
                write invalid-line          from input-line
           else
                add 1                       to ws-valid-records
                write valid-line            from input-line
           end-if.

           move input-line                  to ws-input-data-out.
           move il-tran-code                to ws-tran-code-out.
           move il-tran-amount              to ws-tran-amount-out.
           move il-pay-type                 to ws-pay-type-out.
           move il-store-num                to ws-store-num-out.
           move il-invoice-num              to ws-invoice-num-out.
           move il-sku-code                 to ws-sku-out.
           write output-line                from ws-detail-line.
           move  ws-no-flag                 to ws-error-flag.

       500-printtotals.
           write output-line                from ws-blank-line.
           move ws-error-count              to ws-error-count-out.
           write output-line                from ws-headings-3.

       600-closefiles.
           close input-file,
                 valid-file,
                 invalid-file,
                 output-file.
      *
      *

       end program A6EDIT.

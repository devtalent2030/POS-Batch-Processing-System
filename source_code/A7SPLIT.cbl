       identification division.
       program-id. A7SPLIT.
       date-written. 08-01-2024.
       author. TALENT NYOTA.
      *Description: A7 Split Program
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

            select sl-file
               assign to SLFILE
               organization is sequential.

            select ret-file
               assign to RETFILE
               organization is sequential.
      *
      * output-file declaration
           select output-file
               assign to OUTFILE
               organization is sequential.
      *
       data division.
       file section.
      *

       fd input-file
           recording mode is F
           data record is input-line
           record contains 36 characters.

      **********************************************
       01 input-line.
           05 il-tran-code                  pic x.
           05 il-tran-amount                pic 9(5)V99.
           05 il-store-num                  pic 99.
           05 il-invoice-num                pic x(9).
           05 il-sku-code                   pic x(15).

      ************************************************

       fd sl-file
           recording mode is F
           data record is sl-line
           record contains 36 characters.

       01 sl-line                        pic x(36).

      **********************************************

       fd ret-file
           recording mode is F
           data record is ret-line
           record contains 36 characters.

       01 ret-line                      pic x(36).

      **********************************************
       fd output-file
           recording mode is F
           data record is output-line
           record contains 190 characters.
      *
       01 output-line                       PIC X(190).
      *
       working-storage section.

       01 ws-eof-flag                       pic x
           value 'N'.
       01 ws-no-flag                        pic x
           value 'N'.
       01 ws-yes-flag                       pic x
           value 'Y'.

       01 ws-blank-line.
          05 filler                         pic x(190).

       01 ws-counters.
           05 ws-sl-total                   pic 999.
           05 ws-s-total                    pic 999.
           05 ws-l-total                    pic 999.
           05 ws-r-total                    pic 999.
           05 ws-grand-total                pic 9(6)V99.

       01 ws-tran-amount-totals.
           05 ws-sl-total-amount            pic 9(6)V99.
           05 ws-s-total-amount             pic 9(6)V99.
           05 ws-l-total-amount             pic 9(6)V99.
           05 ws-r-total-amount             pic 9(6)V99.
           05 ws-grand-total-amount         pic 9(8)V99.

       01 ws-headings-titles.
           05 filler                        pic x(10)
                value "Tran. Code".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(12)
                value "Store Number".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(18)
                value "Store Total Amount".

       01 ws-headings-1.
           05 filler                        pic x(173)
                value "Totals for Valid Records".
           05 filler                        pic x(17)
                value "Miguel Stoyke, A7".

       01 ws-headings-totals.
           05 filler                        pic x(15)
                value "Total S Amount".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(15)
                value "Total L Amount".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(18)
                value "Total S&L Amount".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(14)
                value "Total R Amount".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(19)
                value "Grand Total Amount".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(13)
                value "Total S Count".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(13)
                value "Total L Count".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(16)
                value "Total S&L Count".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(13)
                value "Total R Count".
           05 filler                        pic x(3)
                value spaces.
           05 filler                        pic x(17)
                value "Grand Total Count".



       01 ws-detail-line.
           05 filler                        pic x(5)
                value spaces.
           05 ws-tran-code-out              pic x.
           05 filler                        pic x(12)
                value spaces.
           05 ws-store-num-out              pic 99.
           05 filler                        pic x(12)
                value spaces.
           05 ws-tran-amount-out            pic Z(4)9.99.

       01 ws-detail-line-totals.
           05 filler                        pic x(2)
                value spaces.
           05 ws-s-tot-out                  pic $ZZZ,ZZZ.99.
           05 filler                        pic x(7)
                value spaces.
           05 ws-l-tot-out                  pic $ZZZ,ZZZ.99.
           05 filler                        pic x(7)
                value spaces.
           05 ws-sl-tot-out                 pic $ZZZ,ZZZ.99.
           05 filler                        pic x(10)
                value spaces.
           05 ws-r-tot-out                  pic $ZZZ,ZZZ.99.
           05 filler                        pic x(6)
                value spaces.
           05 ws-grand-tot-out              pic $ZZZ,ZZZ.99.
           05 filler                        pic x(14)
                value spaces.

           05 ws-s-out                      pic zz9.
           05 filler                        pic x(13)
                value spaces.
           05 ws-l-out                      pic zz9.
           05 filler                        pic x(13)
                value spaces.
           05 ws-sl-out                     pic zz9.
           05 filler                        pic x(16)
                value spaces.
           05 ws-r-out                      pic zz9.
           05 filler                        pic x(14)
                value spaces.
           05 ws-grand-out                  pic zz9.



      *
       procedure division.
       000-main.
           perform 100-openfiles.
           perform 200-writeheadings.
           perform 300-initialread.
           perform 400-processrecords
                until ws-eof-flag = ws-yes-flag.
           perform 500-writetotals.
           perform 600-closefiles.


           goback.

       100-openfiles.
           open input  input-file.
           open output output-file,
                       sl-file,
                       ret-file.

       200-writeheadings.
           write output-line               from ws-headings-1.
           write output-line               from ws-blank-line.
           write output-line               from ws-headings-titles.
           write output-line               from ws-blank-line.

       300-initialread.
           read input-file
                at end move ws-yes-flag     to ws-eof-flag.

       400-processrecords.
           perform 420-splitrecords.

           read input-file
                at end move ws-yes-flag     to ws-eof-flag.

       420-splitrecords.
           if il-tran-code = 'S'
                add 1                       to ws-s-total
                add 1                       to ws-sl-total
                add 1                       to ws-grand-total
                add il-tran-amount          to ws-s-total-amount
                add il-tran-amount          to ws-sl-total-amount
                add il-tran-amount          to ws-grand-total-amount

                move il-tran-code           to ws-tran-code-out
                move il-store-num           to ws-store-num-out
                move il-tran-amount         to ws-tran-amount-out

                write output-line           from ws-detail-line
                write sl-line               from input-line
           else
           if il-tran-code = 'L'
                add 1                       to ws-l-total
                add 1                       to ws-sl-total
                add 1                       to ws-grand-total
                add il-tran-amount          to ws-l-total-amount
                add il-tran-amount          to ws-sl-total-amount
                add il-tran-amount          to ws-grand-total-amount

                move il-tran-code           to ws-tran-code-out
                move il-store-num           to ws-store-num-out
                move il-tran-amount         to ws-tran-amount-out

                write output-line           from ws-detail-line
                write sl-line               from input-line
           else
           if il-tran-code = 'R'
                add 1                       to ws-r-total
                add 1                       to ws-grand-total
                add il-tran-amount          to ws-r-total-amount
                subtract il-tran-amount     from ws-grand-total-amount

                move il-tran-code           to ws-tran-code-out
                move il-store-num           to ws-store-num-out
                move il-tran-amount         to ws-tran-amount-out

                write output-line           from ws-detail-line
                write ret-line              from input-line
           end-if
           end-if
           end-if.

      *    SUBTRACT ws-r-total-amount FROM ws-grand-total-amount.

       500-writetotals.
           move ws-s-total                  to ws-s-out.
           move ws-l-total                  to ws-l-out.
           move ws-sl-total                 to ws-sl-out.
           move ws-r-total                  to ws-r-out.
           move ws-grand-total              to ws-grand-out.

           move ws-s-total-amount           to ws-s-tot-out.
           move ws-l-total-amount           to ws-l-tot-out.
           move ws-sl-total-amount          to ws-sl-tot-out.
           move ws-r-total-amount           to ws-r-tot-out.
           move ws-grand-total-amount       to ws-grand-tot-out.

           write output-line                from ws-blank-line.
           write output-line                from ws-headings-totals.
           write output-line                from ws-detail-line-totals.


       600-closefiles.
           close input-file,
                 sl-file,
                 ret-file,
                 output-file.


      *
       end program A7SPLIT.
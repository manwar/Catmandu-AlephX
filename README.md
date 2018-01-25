# NAME

    Catmandu::AlephX - Low level client for Aleph X-Services

# SYNOPSIS

    my $aleph = Catmandu::AlephX->new(url => "http://localhost/X");
    my $item_data = $aleph->item_data(base => "rug01",doc_number => "001484477");


    #all public methods return a Catmandu::AlephX::Response
    # 'is_success' means that the xml-response did not contain the element 'error'
    # most methods return only one 'error', but some (like update_doc) multiple.
    # other errors are thrown (xml parse error, no connection ..)


    if($item_data->is_success){

      say "valid response from aleph x server";

    }else{

      say "aleph x server returned error-response: ".join("\n",@{$item_data->errors});

    }

# METHODS

## item-data

### documentation from AlephX

The service retrieves the document number from the user.
For each of the document's items it retrieves:
  Item information (From Z30).
  Loan information (from Z36).
  An indication whether the request is on-hold

### example

    my $item_data = $aleph->item_data(base => "rug01",doc_number => "001484477");
    if($item_data->is_success){
      for my $item(@{ $item_data->items() }){
        print Dumper($item);
      };
    }else{
      print STDERR join("\n",@{$item_data->errors})."\n";
    }

### remarks

    This method is equivalent to 'op' = 'item-data'

## item-data-multi

### documentation from AlephX

This service takes a document number from the user and for each of the document's items retrieves the following:
  Item information (from Z30)
  Loan information (from Z36)
An indication of whether or not the item is on hold, has hold requests, or is expected (that is, has not arrived yet but is expected)
It is similar to the item\_data X-service, except for the parameter START\_POINT, which enables the retrieval of information for documents with more than 1000 items.

### example

    my $item_data_m = $aleph->item_data_multi(base => "rug01",doc_number => "001484477",start_point => '000000990');
    if($item_data_m->is_success){
      for my $item(@{ $item_data_m->items() }){
        print Dumper($item);
      };
    }else{
      print STDERR join("\n",@{$item_data_m->errors})."\n";
    }

    say "items retrieved, starting at ".$item_data_m->start_point() if $item_data_m->start_point();

### remarks

    This method is equivalent to 'op' = 'item-data-multi'
    The attribute 'start_point' only supplies a value, if the document has over 990 items

## read\_item

### documentation from AlephX

    The service retrieves a requested item's record from a given ADM library in case such an item does exist in that ADM library.

### example

    my $readitem = $aleph->read_item(library=>"usm50",item_barcode=>293);
    if($readitem->is_success){
      for my $z30(@{ $readitem->z30 }){
        print Dumper($z30);
      }
    }else{
      say STDERR join("\n",@{$readitem->errors});
    }

### remarks

    This method is equivalent to 'op' = 'read-item'

## find

### documentation from Aleph X

    This service retrieves a set number and the number of records answering a search request inserted by the user.

### example

    my $find = $aleph->find(request => 'wrd=(art)',base=>'rug01');
    if($find->is_success){
      say "set_number: ".$find->set_number;
      say "no_records: ".$find->no_records;
      say "no_entries: ".$find->no_entries;
    }else{
      say STDERR join("\n",@{$find->errors});
    }

### remarks

    This method is equivalent to 'op' = 'find'

### arguments

    request - search request
    adjacent - if 'Y' then the documents should contain all the search words adjacent to each other, otherwise 'N'

## find\_doc

### documentation from AlephX

    This service retrieves the OAI XML format of an expanded document as given by the user.

### example

    my $find = $aleph->find_doc(base=>'rug01',doc_num=>'000000444',format=>'marc');
    if($find->is_success){
      say Dumper($find->record);
    }else{
      say STDERR join("\n",@{$find->errors});
    }

### remarks

    This method is equivalent to 'op' = 'find-doc'

## present

### documentation from Aleph X

    This service retrieves OAI XML format of expanded documents.
    You can view documents according to the locations within a specific set number.

### example

    my $set_number = $aleph->find(request => "wrd=(BIB.AFF)",base => "rug01")->set_number;
    my $present = $aleph->present(
      set_number => $set_number,
      set_entry => "000000001-000000003"
    );
    if($present->is_success){
      for my $record(@{ $present->records() }){
        say "doc_number: ".$record->doc_number;
        say "\tmetadata: ".$record->metadata->type;
      }
    }else{
      say STDERR join("\n",@{$present->errors});
    }

### remarks

    This method is equivalent to 'op' = 'present'

## ill\_get\_doc\_short

### documentation from Aleph X

    The service retrieves the doc number and the XML of the short document (Z13).

### example

    my $result = $aleph->ill_get_doc_short(doc_number => "000000001",library=>"usm01");
    if($result->is_success){
      for my $z30(@{ $result->z13 }){
        print Dumper($z30);
      }
    }else{
      say STDERR join("\n",@{$result->errors});
    }

### remarks

    This method is equivalent to 'op' = 'ill-get-doc-short'

## bor\_auth

### documentation from Aleph X

    This service retrieves the Global record (Z303), Local record (Z305) and the Data record (Z304) for a given Patron if the given ID and verification code match.
    Otherwise, an error message is returned.

### example

    my %args = (
      library => $library,
      bor_id => $bor_id,
      verification => $verification
    );
    my $auth = $aleph->bor_auth(%args);

    if($auth->is_success){

      for my $type(qw(z303 z304 z305)){
        say "$type:";
        my $data = $auth->$type();
        for my $key(keys %$data){
          say "\t$key : $data->{$key}->[0]";
        }
      }

    }else{
      say STDERR "error: ".join("\n",@{$auth->errors});
      exit 1;
    }

## bor\_info

### documentation from Aleph X

    This service retrieves all information related to a given Patron: Global and Local records, Loan records, Loaned items records, Short doc record, Cash record, and so on, if the ID and verification code provided match.

    If not, an error message is returned. Since the bor-info X-Service retrieves a very large amount of data, and not all of it may be relevant, you can choose to receive a part of the data, based on your needs.

### example

    my %args = (
      library => $library,
      bor_id => $bor_id,
      verification => $verification,
      loans => 'P'
    );
    my $info = $aleph->bor_info(%args);

    if($info->is_success){

      for my $type(qw(z303 z304 z305)){
        say "$type:";
        my $data = $info->$type();
        for my $key(keys %$data){
          say "\t$key : $data->{$key}->[0]";
        }
      }
      say "fine:";
      for my $fine(@{ $info->fine() }){
        for my $type(qw(z13 z30 z31)){
          say "\t$type:";
          my $data = $fine->{$type}->[0];
          for my $key(keys %$data){
            say "\t\t$key : $data->{$key}->[0]";
          }
        }
      }

    }else{
      say STDERR "error: ".join("\n",@{$info->errors});
      exit 1;
    }

## ill\_bor\_info

### documentation from Aleph X

    This service retrieves Z303, Z304, Z305 and Z308 records for a given borrower ID / barcode.

### example

## circ\_status

### documentation from Aleph X

The service retrieves the circulation status for each document number entered by the user.

    Item information (From Z30).
    Loan information (from Z36).
    Loan Status (Tab15), Due Date, Due Hour etc.

### example

## circ\_stat\_m

### documentation from Aleph X

The service retrieves the circulation status for each document number entered by the user (suitable for documents with more than 1000 items).

    Item information (From Z30).
    Loan information (from Z36).
    Loan Status (Tab15), Due Date, Due Hour etc.

This service is similar to circ-status X-service, except for the parameter START\_POINT which enables to retrieve information for documents with more than 1000 items.

### example

## publish\_avail

### documentation from Aleph X

This service supplies the current availability status of a document.

The X-Server does not change any data.

### example

my $publish = $aleph->publish\_avail(doc\_num => '000196220,001313162,001484478,001484538,001317121,000000000',library=>'rug01');
if($publish->is\_success){

    #format for $publish->list() : [ [<id>,<marc-array>], .. ]

    for my $item(@{ $publish->list }){

      say "id: $item->[0]";
      if($item->[1]){
        say "marc array:";
        say Dumper($item->[1]);
      }else{
        say "nothing for $item->[0]";
      }

      say "\n---";
    }
  }else{
    say STDERR join("\n",@{$publish->errors});
  }

### remarks

    The parameter 'doc_num' supports multiple values, separated by ','.
    Compare this to ill_get_doc, that does not support this.

## ill\_get\_doc

### documentation from Aleph X

This service takes a document number and the library where the corresponding document is located and generates the XML of the requested document as it appears in the library given.

### example

my $illgetdoc = $aleph->ill\_get\_doc(doc\_number => '001317121',library=>'rug01');
if($illgetdoc->is\_success){

    if($illgetdoc->record){
      say "data: ".to_json($illgetdoc->record,{ pretty => 1 });
    }
    else{
      say "nothing found";
    }

}else{
  say STDERR join("\\n",@{$illgetdoc->errors});
}

## renew

### documentation from Aleph X

    This service renews the loan of a given item for a given patron.
    The X-Service renews the loan only if it can be done. If, for example, there is a delinquency on the patron, the service does not renew the loan.

### example

## hold\_req

### documentation from Aleph X

The service creates a hold-request record (Z37) for a given item after performing initial checks.

### example

## update\_doc

### documentation from Aleph X

    The service performs actions (Update / Insert / Delete) related to the update of a document.
    (The service uses pc_cat_c0203 which updates a document via the GUI).

### notes

    When executing an update request, most of the 'errors' will be warnings instead of real errors.
    This happens because AlephX performs an 'UPDATE-CHK' before trying to execute an 'UPDATE',
    and stores all warnings during that check in the xml attribute 'error'.

    Therefore the method 'is_success' of the Catmandu::AlephX::Response is not very usefull in this case.
    Search for the last 'error', and check wether it contains 'updated successfully'.

### warnings

    An updates replaces the WHOLE record. So if you fail to supply 'xml_full_req' (or indirectly 'marc'),
    the record will be deleted!

    To be sure, please use the full xml response of 'find-doc', change the fields inside 'oai_marc', and
    supply this xml as xml_full_req.

    Every updates adds a CAT-field to the record. Your updates can be recognized by CAT$$a == "WWW-X".
    When updating a record you need to include the old CAT fields (default), otherwise these fields will be deleted
    (and all history will be lost).

    "Unlike other X-Services, the parameters can include XML up to 20,000 characters in length"

    When you update often (and therefore add a lot of CAT fields), this can lead to the error 'Server closed connection'.
    This is due to the maximum of characters allowed in an XML request.

    Possible solution:
      1. retrieve record by 'find_doc'
      2. get marc record:

          my $marc = $res->record->metadata->data

      3. filter out your CAT fields ($a == "WWW-X") to shorten the XML:

          $marc = [grep { !( $_->[0] eq "CAT" && $_->[4] eq "WWW-X" ) } @$marc];

      4. update $marc
      5. send

          $aleph->update_doc(library => 'usm01',doc_action => 'UPDATE',doc_number => $doc_number,marc => $marc);

          => your xml will now contain one CAT field with subfield 'a' equal to 'WWW-X'.

### example

    my $aleph = Catmandu::AlephX->new(url => "http://localhost/X");

    my $doc_number = '000000444';
    my $find_doc = $aleph->find_doc(
      doc_num => $doc_number,
      base => "usm01"
    );
    my $marc = $find_doc->record->metadata->data;
    my $content_ref = $find_doc->content_ref;

    my %args = (
      'library' => 'usm01',
      'doc_action' => 'UPDATE',
      'doc_number' => $doc_number,
      xml_full_req => $$content_ref
    );
    my $u = $aleph->update_doc(%args);
    if($u->is_success){
      say "all ok";
    }else{
      say STDERR join("\n",@{$u->errors});
    }

### special support for catmandu marc records

    when you supply the argument 'marc', an xml document will be created for you,
    and stored in the argument 'xml_full_req'. 'marc' must be an array of arrays.
    When you already supplied 'xml_full_req', it will be overwritten.

## update\_item

### documentation from Aleph X

    The service updates an existing item in the required ADM library after performing all relevant initial checks prior to that action.

### notes

    AlephX stores not only errors in 'errors', but also the success message.

    Therefore the method 'is_success' of the Catmandu::AlephX::Response is not very usefull in this case.
    Search for the last 'error', and check wether it contains 'updated successfully'.

    The result of 'read_item' often contains translations, instead of the real values. But these
    translation cannot be used when updating items.

    e.g. z30-item-status contains 'Regular loan' instead of '001'.

### example

    my $alephx = Catmandu::AlephX->new(url => "http://localhost/X");
    my $item_barcode = '32044044980076';

    my %args = (
      'library' => 'usm50',
      'item_barcode' => $item_barcode,
    );

    my $z30 = $alephx->read_item(%args)->z30();

    my $xml = XMLout($z30,,RootName=>"z30",NoAttr => 1);
    $xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n".$xml;

    $args{xml_full_req} = $xml;

    my $u = alephx->update_item(%args);
    if($u->is_success){
      say "all ok";
    }else{
      say STDERR join("\n",@{$u->errors});
    }

## create\_item

### documentation from Aleph X

The service creates a new item in the required ADM library after performing all relevant initial checks prior to that action.

The item can be created for a bib record when no ADM record is linked to it yet, or it can be created to an ADM record with existing items.

### notes

### example

    my $alephx = Catmandu::AlephX->new(url => "http://localhost/X");
    my $item_barcode = '32044044980076';

    my %args = (
      'adm_library'    => 'rug50',
      'bib_library'    => 'rug01',
      'bib_doc_number' => '231843137',
    );

    my $xml = <<EOF;
    <?xml version="1.0" encoding="UTF-8" ?>
    <z30>
    <z30-doc-number>15</z30-doc-number>
    <z30-item-sequence>10</z30-item-sequence>
    <z30-barcode>32044003924339</z30-barcode>
    <z30-sub-library>WID</z30-sub-library>
    <z30-material>BOOK</z30-material>
    <z30-item-status>01</z30-item-status>
    <z30-open-date>19980804</z30-open-date>
    <z30-update-date>20020708</z30-update-date>
    <z30-cataloger>EXLIBRIS</z30-cataloger>
    <z30-date-last-return>20080607</z30-date-last-return>
    <z30-hour-last-return>1631</z30-hour-last-return>
    <z30-ip-last-return>CONV</z30-ip-last-return>
    <z30-no-loans>011</z30-no-loans>
    <z30-alpha>L</z30-alpha>
    <z30-collection>GEN</z30-collection>
    <z30-call-no-type>7</z30-call-no-type>
    <z30-call-no>Heb 2106.385.5</z30-call-no>
    <z30-call-no-key>7 selected</z30-call-no-key>
    <z30-call-no-2-type />
    <z30-call-no-2 />
    <z30-call-no-2-key />
    <z30-description>v.1</z30-description>
    <z30-note-opac />
    <z30-note-circulation />
    <z30-note-internal />
    <z30-order-number />
    <z30-inventory-number />
    <z30-inventory-number-date />
    <z30-last-shelf-report-date>00000000</z30-last-shelf-report-date>
    <z30-price />
    <z30-shelf-report-number />
    <z30-on-shelf-date>00000000</z30-on-shelf-date>
    <z30-on-shelf-seq>000000</z30-on-shelf-seq>
    <z30-doc-number-2>000000015</z30-doc-number-2>
    <z30-schedule-sequence-2>00000</z30-schedule-sequence-2>
    <z30-copy-sequence-2>00000</z30-copy-sequence-2>
    <z30-vendor-code />
    <z30-invoice-number />
    <z30-line-number>00000</z30-line-number>
    <z30-pages />
    <z30-issue-date />
    <z30-expected-arrival-date />
    <z30-arrival-date />
    <z30-item-statistic />
    <z30-item-process-status>XX</z30-item-process-status>
    <z30-copy-id>1</z30-copy-id>
    <z30-hol-doc-number>000000046</z30-hol-doc-number>
    <z30-temp-location>No</z30-temp-location>
    <z30-enumeration-a />
    <z30-enumeration-b />
    <z30-enumeration-c />
    <z30-enumeration-d />
    <z30-enumeration-e />
    <z30-enumeration-f />
    <z30-enumeration-g />
    <z30-enumeration-h />
    <z30-chronological-i />
    <z30-chronological-j />
    <z30-chronological-k />
    <z30-chronological-l />
    <z30-chronological-m />
    <z30-supp-index-o />
    <z30-85x-type />
    <z30-depository-id />
    <z30-linking-number>000000000</z30-linking-number>
    <z30-gap-indicator />
    <z30-maintenance-count>007</z30-maintenance-count>
    <z30-process-status-date>20080408</z30-process-status-date>
    </z30>
  EOF

    $args{xml_full_req} = $xml;

    my $u = alephx->create_item(%args);
    if($u->is_success){
      say "all ok";
    }else{
      say STDERR join("\n",@{$u->errors});
    }

# AUTHOR

Nicolas Franck, `<nicolas.franck at ugent.be>`

# LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
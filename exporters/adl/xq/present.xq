xquery version "3.0" encoding "UTF-8";

declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace file="http://exist-db.org/xquery/file";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace app="http://kb.dk/this/app";
declare namespace t="http://www.tei-c.org/ns/1.0";
declare namespace ft="http://exist-db.org/xquery/lucene";



declare variable  $document := request:get-parameter("doc","");
declare variable  $frag     := request:get-parameter("id","");
declare variable  $c        := request:get-parameter("c","texts");
declare variable  $o        := request:get-parameter("op","render");
declare variable  $coll     := concat("/db/adl/",$c);
declare variable  $op       := doc(concat("/db/adl/", $o,".xsl"));
declare variable  $au_url   := concat($c,'/',$document);

declare option exist:serialize "method=xml encoding=UTF-8 media-type=text/xml";

let $list := 
 (: if($frag and not($o = "facsimile")) then
    for $doc in collection($coll)//node()[ft:query(@xml:id,$frag)]
    where util:document-name($doc)=$document
    return $doc
  else :)
    for $doc in collection($coll)
    where util:document-name($doc)=$document
    return $doc

let $author_id := doc('/db/adl/creator-relations.xml')//t:row[t:cell/t:ref = $au_url]/t:cell[@role='author']

let $params := 
<parameters>
   <param name="hostname"  value="{request:get-header('HOST')}"/>
   <param name="doc"       value="{$document}"/>
   <param name="id"        value="{$frag}"/>
   <param name="c"         value="{$c}"/>
   <param name="coll"      value="{$coll}"/>
   <param name="auid"      value="{$author_id}"/>
</parameters>

for $doc in $list
return  transform:transform($doc,$op,$params) 

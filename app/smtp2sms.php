#!/usr/bin/php

<?php

require_once __DIR__.'/vendor/autoload.php';

$parser = new PhpMimeMailParser\Parser();
$parser->setStream(fopen("php://stdin", "r"));
$to = $parser->getAddresses('to');
$body = trim($parser->getMessageBody('text'));
$curl = curl_init();

$sms_apikey="%SMS_APIKEY%";
$sms_from="%SMS_FROM%";

foreach($to as $recipient) {
  $arr = explode('@', $recipient['address']);
  /** echo $arr[0] . PHP_EOL;
  echo $body; **/
  $url = 'https://mm.inmobile.dk/Api/V2/Get/SendMessages?apiKey=' . $sms_apikey . '&sendername=' . urlencode($sms_from) . '&recipients=' . urlencode($arr[0]) . '&text=' . urlencode($body);
  curl_setopt($curl, CURLOPT_URL, $url);
  curl_setopt($curl, CURLOPT_FAILONERROR, true);
  if(!curl_exec($curl)) {
    die('Error: "' . curl_error($curl) . '" - Code: ' . curl_errno($curl));
  }

}

import 'package:flutter/foundation.dart';

class ApiConfigurations{
 static String BaseUrl = kReleaseMode ? "https://www.test.com:1024/api" : "http://192.168.1.16:15265/api";
 static String ImagesBaseUrl = "https://www.test.com";
 static String WebsiteBaseUrl = "https://www.test.com";
 static String WhatsAppBaseUrl = "whatsapp://send?phone=905340000000&text=";
 static String WhatsAppShareBaseUrl = "whatsapp://send?text=";
 static int HttpGetTimeout = 25;
 static int HttpPostTimeout = 25;


 static Map<String, String> JsonContentType = <String, String>{
  'Content-Type': 'application/json; charset=UTF-8',
 };
}

class AppConfigurations{
 static String productPlaceHolderImage = "assets/images/product-notfound.png";
}
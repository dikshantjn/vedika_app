class ApiConstants {
  // Use your actual keys here
  static const String razorpayApiKey = "rzp_test_uMMypIJ2X2bn1N";

  // PhonePe credentials
  static const String phonePeMerchantId = "M2202R7N3WE25"; // Test merchant ID
  static const String phonePeSaltKey = "39b01084-baa0-431b-b44e-3ae4e08a4360"; // Test salt key
  static const int phonePeSaltKeyIndex = 1;
  static const String phonePeAppId = "com.vedika.heath.vedika_healthcare"; // Your app's package name
  static const String phonePeApiEndpoint = "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/pay";
  static const String phonePeCallbackUrl = "https://webhook.site/0fa9bfdc-33a8-4f93-ab93-111e4a25bb03"; // Your callback URL
  static const String phonePeRedirectUrl = "https://webhook.site/0fa9bfdc-33a8-4f93-ab93-111e4a25bb03";

  // Google Vision API
  static const String googleVisionApiKey = "AIzaSyDIFRThseqk53zAOQ6hEv-meLn0B4SIVmM";
  static const String googleVisionApiEndpoint = "https://vision.googleapis.com/v1/images:annotate";
}

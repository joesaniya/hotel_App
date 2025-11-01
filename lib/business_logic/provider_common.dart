import 'package:hotel_app/business_logic/app_settings_provider.dart';
import 'package:hotel_app/business_logic/auth-provider.dart';
import 'package:hotel_app/business_logic/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ProviderHelperClass {
  static ProviderHelperClass? _instance;

  static ProviderHelperClass get instance {
    _instance ??= ProviderHelperClass();
    return _instance!;
  }

  List<SingleChildWidget> providerLists = [
    // ChangeNotifierProvider(create: (context) => SplashProvider(context)),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => HomeProvider()),
    ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
  ];
}

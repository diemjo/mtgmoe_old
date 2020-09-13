import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/model/app_state_model.dart';
import 'package:MTGMoe/tabs/card_list_tab.dart';
import 'package:MTGMoe/tabs/home_tab.dart';
import 'package:MTGMoe/tabs/settings_tab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializePreferences();
  runApp(
    ChangeNotifierProvider<AppStateModel>(
      create: (_) => AppStateModel(),
      child: App(),
    )
  );
}

Future<void> initializePreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> defaultEnabledSetTypes = ['expansion', 'core', 'masterpiece'];
  defaultEnabledSetTypes.forEach((setType) {
    String prefKey = 'set_type_'+setType;
    if (!prefs.containsKey(prefKey))
      prefs.setBool(prefKey, true);
  });
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Brightness brightness = Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final materialTheme = new ThemeData(
      primarySwatch: Colors.purple,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: { TargetPlatform.android: CupertinoPageTransitionsBuilder() }
      )
    );
    final materialDarkTheme = new ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.purple,
    );

    final cupertinoTheme = new CupertinoThemeData(
      brightness: brightness, // if null will use the system theme
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: Colors.purple,
        darkColor: Colors.cyan,
      ),
    );

    // Example of optionally setting the platform upfront.
    //final initialPlatform = TargetPlatform.iOS;

    // If you mix material and cupertino widgets together then you cam
    // set this setting. Will mean ios darmk mode to not to work properly
    //final settings = PlatformSettingsData(iosUsesMaterialWidgets: true);

    // This theme is required since icons light/dark mode will look for it
    return Theme(
      data: materialDarkTheme,
      child: PlatformProvider(
        //initialPlatform: initialPlatform,
        // settings: PlatformSettingsData(
        //   platformStyle: PlatformStyleData(
        //     android: PlatformStyle.Cupertino,
        //   ),
        // ),
        builder: (context) => PlatformApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          title: 'MTGMoe',
          material: (_, __) {
            return new MaterialAppData(
              theme: materialTheme,
              darkTheme: materialDarkTheme,
              themeMode: ThemeMode.dark,
            );
          },
          cupertino: (_, __) => new CupertinoAppData(
            theme: cupertinoTheme,
          ),
          home: LandingPage(),
        ),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin{

  PlatformTabController _tabController;

  AnimationController rotationController;

  List<BottomNavigationBarItem> _items(BuildContext context) {
    return [
      BottomNavigationBarItem(
          title: Text('Home'),
          icon: Icon(context.platformIcons.home,
              color: MoeStyle.navigationBarIconColor),
          activeIcon: Icon(context.platformIcons.home,
              color: MoeStyle.navigationBarIconColorActive)
      ),
      BottomNavigationBarItem(
          title: Text('Cards'),
          icon: Icon(context.platformIcons.collections,
              color: MoeStyle.navigationBarIconColor),
          activeIcon: Icon(context.platformIcons.collections,
              color: MoeStyle.navigationBarIconColorActive)
      ),
      BottomNavigationBarItem(
        title: Text('Settings'),
        icon: settingsAnimationWrap(
            context: context,
            child: Icon(context.platformIcons.settings, color: MoeStyle.navigationBarIconColor)),
        activeIcon: settingsAnimationWrap(
          context: context,
          child: Icon(context.platformIcons.settings, color: MoeStyle.navigationBarIconColorActive),
        ),
      ),
    ];
  }

  Widget settingsAnimationWrap({@required BuildContext context, @required Widget child}) {
    if (rotationController != null && Provider.of<AppStateModel>(context).updateStatus!=UpdateStatus.IDLE) {
      return AnimatedBuilder(
        animation: rotationController,
        child: child,
        builder: (context, child) => Transform.rotate(angle: rotationController.value, child: child),
      );
    } else {
      return child;
    }
  }

  Widget _contentBuilder(BuildContext context, int index) {
    switch (index) {
      case 0: return HomeTab();
      case 1: return CardsTab();
      case 2: return SettingsTab();
      default: return null;
    }
  }


  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    if (_tabController == null) {
      _tabController = PlatformTabController(initialIndex: 0);
    }
    if (rotationController == null) {
      rotationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
      rotationController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformTabScaffold(
      iosContentPadding: true,
      tabController: _tabController,
      bodyBuilder: _contentBuilder,
      items: _items(context),
      pageBackgroundColor: MoeStyle.defaultAppColor,
      materialTabs: (context, platform) {
        return MaterialNavBarData(selectedItemColor: MoeStyle.navigationBarIconColorActive);
      },
      cupertinoTabs: (context, platform) {
        return CupertinoTabBarData(activeColor: MoeStyle.navigationBarIconColorActive);
      },
    );
  }
}

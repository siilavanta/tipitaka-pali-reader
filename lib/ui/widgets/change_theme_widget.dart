import 'package:tipitaka_pali/services/provider/theme_change_notifier.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tipitaka_pali/services/prefs.dart';

class ChangeThemeWidget extends StatelessWidget {
  const ChangeThemeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeChangeNotifier>(context);

    return Switch(
      value: Prefs.lightThemeOn,
      activeThumbImage: AssetImage("assets/sun.png"),
      inactiveThumbImage: AssetImage("assets/moon.png"),
      onChanged: (value) {
        final provider =
            Provider.of<ThemeChangeNotifier>(context, listen: false);
        Prefs.lightThemeOn = value;
        provider.toggleTheme(value);
      },
    );
  }
}
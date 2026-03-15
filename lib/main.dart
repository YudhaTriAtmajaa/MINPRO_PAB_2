import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/refresh_notifier.dart';
import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RefreshNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toko Baju Muslim',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashPage(),
    );
  }
}

class AppTheme {
  static const cream = Color(0xFFF8F5F0);
  static const darkGreen = Color(0xFF1A3A2A);
  static const accentGold = Color(0xFFC8A96E);
  static const textDark = Color(0xFF1C1C1C);
  static const textMid = Color(0xFF5A5A5A);
  static const textLight = Color(0xFF9A9A9A);
  static const dividerColor = Color(0xFFE8E2D9);

  static const darkText1 = Color(0xFFF0F0F0);
  static const darkText2 = Color(0xFFCCCCCC);
  static const darkText3 = Color(0xFF888888);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: const ColorScheme.light(
      primary: darkGreen,
      secondary: accentGold,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 2,
      shadowColor: Colors.black12,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkGreen,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: const Color(0x401A3A2A),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          fontSize: 13,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: dividerColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      labelStyle: const TextStyle(color: textMid, fontSize: 14),
      hintStyle: const TextStyle(color: textLight, fontSize: 14),
      prefixIconColor: textMid,
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: darkGreen,
      labelStyle: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
      side: const BorderSide(color: dividerColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textDark),
      bodyMedium: TextStyle(color: textDark),
      bodySmall: TextStyle(color: textMid),
      titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0F0F0F),
    colorScheme: const ColorScheme.dark(
      primary: accentGold,
      secondary: Color(0xFF4A8A5A),
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSurface: darkText1,
      onSecondaryContainer: darkText1,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: darkText1,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: darkText1,
        letterSpacing: 2,
      ),
      iconTheme: IconThemeData(color: darkText1),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentGold,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGold,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: const Color(0x60C8A96E),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentGold, width: 2),
      ),
      labelStyle: const TextStyle(color: darkText3, fontSize: 14),
      hintStyle: const TextStyle(color: darkText3, fontSize: 14),
      prefixIconColor: darkText3,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black54,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme:
        const DividerThemeData(color: Color(0xFF2A2A2A), thickness: 1),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkText1),
      bodyMedium: TextStyle(color: darkText2),
      bodySmall: TextStyle(color: darkText3),
      titleLarge: TextStyle(color: darkText1, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: darkText1, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(color: darkText3),
    ),
  );
}

package com.example.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme =
  darkColorScheme(
    primary = CoffeeGold,
    secondary = CoffeeDarkAccent,
    tertiary = CoffeeCardBorder,
    background = CoffeeDarkAccent,
    surface = Color(0xFF35312C),
    onPrimary = CoffeeDarkAccent,
    onSecondary = CoffeeGold,
    onBackground = CoffeeBackground,
    onSurface = CoffeeBackground,
  )

private val LightColorScheme =
  lightColorScheme(
    primary = CoffeePrimary,
    secondary = CoffeeSecondary,
    tertiary = CoffeeCardBorder,
    background = CoffeeBackground,
    surface = Color.White,
    onPrimary = Color.White,
    onSecondary = CoffeeTextSub,
    onBackground = CoffeeTextDark,
    onSurface = CoffeeTextDark,
  )


@Composable
fun MyApplicationTheme(
  darkTheme: Boolean = isSystemInDarkTheme(),
  // Dynamic color is available on Android 12+
  dynamicColor: Boolean = true,
  content: @Composable () -> Unit,
) {
  val colorScheme =
    when {
      dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
        val context = LocalContext.current
        if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
      }

      darkTheme -> DarkColorScheme
      else -> LightColorScheme
    }

  MaterialTheme(colorScheme = colorScheme, typography = Typography, content = content)
}

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadThemeFromBox();
  }

  // Load theme from storage
  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  // Save theme to storage
  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  // Toggle theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveThemeToBox(isDarkMode.value);
  }
}


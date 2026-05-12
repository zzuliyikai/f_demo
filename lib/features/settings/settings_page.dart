import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/effect/effect_handler.dart';
import '../../core/localization/string_extension.dart';
import '../../core/theme/app_colors.dart';
import 'settings_cubit.dart';
import 'settings_repo.dart';
import 'settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  static Widget routePage() => BlocProvider<SettingsCubit>(
    create: (context) => SettingsCubit(context.read<SettingsRepo>()),
    child: const SettingsPage(),
  );
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsCubit>().initFromCache();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置'.t)),
      backgroundColor: AppColors.viewBackgroundColor,
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) => EffectHandler.handleEffect(context, state.effect),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListView(
              children: [
                ListTile(
                  title: Text('深色模式'.t),
                  trailing: Switch(
                    value: state.isDarkMode,
                    onChanged: (_) => context.read<SettingsCubit>().toggleDarkMode(),
                  ),
                ),
                ListTile(
                  title: Text('语言'.t),
                  subtitle: Text(state.currentLanguage == 'zh' ? '中文简体'.t : '英语'.t),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguagePicker(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('语言'.t),
        children: [
          SimpleDialogOption(
            child: Text('中文简体'.t),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SettingsCubit>().changeLanguage('zh');
            },
          ),
          SimpleDialogOption(
            child: Text('英语'.t),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SettingsCubit>().changeLanguage('en');
            },
          ),
        ],
      ),
    );
  }
}
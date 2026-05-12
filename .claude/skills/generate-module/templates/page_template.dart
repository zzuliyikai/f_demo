import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexoptim/business_modules/base_logic.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../main_frame/app_effect.dart';
import '../../../main_frame/toast_handler.dart';
import '../../../ui_components/factory/ui_factory.dart';
import '../../../ui_components/ui_theme.dart';
import '___feature_name___cubit.dart';
import '___feature_name___repo.dart';
import '___feature_name___state.dart';

class ___FeatureName___Page extends StatefulWidget {
  const ___FeatureName___Page({super.key});

  @override
  State<___FeatureName___Page> createState() => ___FeatureName___PageState();

  static Widget routePage() => BlocProvider<___FeatureName___Cubit>(
        create: (context) {
          ___FeatureName___Cubit cubit = ___FeatureName___Cubit(
            context.read<___FeatureName___Repo>()
          );
          return cubit;
        },
        child: const ___FeatureName___Page(),
      );
}

class ___FeatureName___PageState extends State<___FeatureName___Page> {
  late final ___FeatureName___Cubit _cubit = context.read<___FeatureName___Cubit>();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  String id = '';

  @override
  void initState() {
    super.initState();
    id = Get.arguments?['id'] ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.initialize(id);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    await _cubit.refreshData();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UIFactory.appBar('页面标题'.t, context),
      backgroundColor: AppColor.viewBackgroundColor,
      body: BlocListener<___FeatureName___Cubit, ___FeatureName___State>(
        listener: (context, state) async {
          if (state.effect is! EffectToastLoading) {
            await ToastHandler.dismissMsg();
          }
          switch (state.effect) {
            case EffectToastLoading():
              ToastHandler.showWaitMsg();
              break;
            case EffectErrorToast<String>(:final value):
              ToastHandler.showMsgWithErrorIcon(value);
              break;
            case EffectSuccessToast<String>(:final value):
              ToastHandler.showMsgWithSuccessIcon(value);
              break;
            default:
              break;
          }
        },
        child: BlocBuilder<___FeatureName___Cubit, ___FeatureName___State>(
          builder: (context, state) {
            return SmartRefresher(
              enablePullDown: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.dp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 在这里添加页面内容
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

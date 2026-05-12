import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../core/effect/effect_handler.dart';
import '../../core/localization/string_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/route_names.dart';
import '../../shared/widgets/loading_widget.dart';
import 'home_cubit.dart';
import 'home_repo.dart';
import 'home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static Widget routePage() => BlocProvider<HomeCubit>(
    create: (context) => HomeCubit(context.read<HomeRepo>()),
    child: const HomePage(),
  );
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit = context.read<HomeCubit>();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.initialize();
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
      appBar: AppBar(
        title: Text('首页'.t),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(RouteNames.settings),
          ),
        ],
      ),
      backgroundColor: AppColors.viewBackgroundColor,
      body: BlocListener<HomeCubit, HomeState>(
        listener: (context, state) => EffectHandler.handleEffect(context, state.effect),
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return LoadingWidget(message: '加载中...'.t);
            }
            return SmartRefresher(
              enablePullDown: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: Center(child: Text(state.title)),
            );
          },
        ),
      ),
    );
  }
}
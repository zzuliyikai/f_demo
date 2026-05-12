import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String? authGuard(BuildContext context, GoRouterState state) {
  // 返回 null 允许访问，返回路径则重定向
  return null;
}
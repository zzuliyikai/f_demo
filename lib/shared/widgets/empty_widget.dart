import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String? message;

  const EmptyWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message ?? '暂无数据', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
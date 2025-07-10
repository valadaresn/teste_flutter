import 'package:flutter/material.dart';
import '../widgets/today_logs_tab.dart';

/// **LogScreen** - Tela principal de visualização de logs
///
/// Interface clean focada na visualização do dia atual com filtros avançados
class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    return const TodayLogsTab();
  }
}

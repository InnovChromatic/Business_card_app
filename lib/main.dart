import 'package:business_card_flutter/app.dart';
import 'package:business_card_flutter/services/business_card_storage_service.dart';
import 'package:business_card_flutter/services/card_storage_service.dart';
import 'package:business_card_flutter/services/notification_storage_service.dart';
import 'package:business_card_flutter/services/profile_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await CardStorageService().initialize();
  await BusinessCardStorageService().initialize();
  await ProfileStorageService().initialize();
  await NotificationStorageService().initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings/widgets/industry_mode_feature_list.dart';

class IndustryModeCard extends StatelessWidget {
  const IndustryModeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final isLoading = state.isLoading;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFF4A7A65),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TraqIcon(
                      AppAssets.iconMedical,
                      color: const Color(0xFF121F17),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Industry Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4E5DC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        settings.industryMode.displayName,
                        style: const TextStyle(
                          color: Color(0xFF121F17),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  settings.industryMode.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const IndustryModeFeatureList(),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: AppColorMapper.errorColor(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

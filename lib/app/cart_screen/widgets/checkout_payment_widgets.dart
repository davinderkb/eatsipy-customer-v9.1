import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:eatsipy_customer/widget/translated_text.dart';
import 'package:flutter/material.dart';

class CheckoutBillSummaryCard extends StatelessWidget {
  final bool isDark;
  final String totalAmount;
  final String? walletAppliedText;
  final VoidCallback onTap;

  const CheckoutBillSummaryCard({
    super.key,
    required this.isDark,
    required this.totalAmount,
    required this.onTap,
    this.walletAppliedText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      "To Pay",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppThemeData.grey400
                            : AppThemeData.grey500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      totalAmount,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                        fontSize: 18,
                      ),
                    ),
                    if (walletAppliedText?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          walletAppliedText!,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            color: AppThemeData.success400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              TranslatedText(
                "View Bill Details",
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  color: AppThemeData.primary300,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_right,
                color: AppThemeData.primary300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutWalletToggleTile extends StatelessWidget {
  final bool isDark;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;
  final IconData icon;

  const CheckoutWalletToggleTile({
    super.key,
    required this.isDark,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeThumbColor: AppThemeData.primary300,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppThemeData.primary300),
      title: TranslatedText(
        title,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
          color: isDark ? AppThemeData.grey50 : AppThemeData.grey900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
          color: isDark ? AppThemeData.grey400 : AppThemeData.grey500,
        ),
      ),
    );
  }
}

class CheckoutPaymentModeTile extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const CheckoutPaymentModeTile({
    super.key,
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: ShapeDecoration(
                color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: AppThemeData.grey200),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(icon, color: AppThemeData.primary300),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    title,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color:
                          isDark ? AppThemeData.grey50 : AppThemeData.grey900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color:
                          isDark ? AppThemeData.grey400 : AppThemeData.grey500,
                    ),
                  ),
                ],
              ),
            ),
            _RadioIndicator(
              isSelected: value == groupValue,
              onTap: () => onChanged(value),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioIndicator({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected ? AppThemeData.primary300 : AppThemeData.grey400,
                width: 2,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: isSelected ? 10 : 0,
                height: isSelected ? 10 : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppThemeData.primary300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

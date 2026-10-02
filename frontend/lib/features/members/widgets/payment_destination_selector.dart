import 'package:flutter/material.dart';

enum MemberPaymentNetwork { airtel, vodacom, orange }

extension MemberPaymentNetworkExtension on MemberPaymentNetwork {
  String get label {
    switch (this) {
      case MemberPaymentNetwork.airtel:
        return 'Airtel Money';

      case MemberPaymentNetwork.vodacom:
        return 'M-Pesa';

      case MemberPaymentNetwork.orange:
        return 'Orange Money';
    }
  }

  IconData get icon {
    switch (this) {
      case MemberPaymentNetwork.airtel:
        return Icons.phone_android_outlined;

      case MemberPaymentNetwork.vodacom:
        return Icons.account_balance_wallet_outlined;

      case MemberPaymentNetwork.orange:
        return Icons.payments_outlined;
    }
  }
}

class PaymentDestinationSelector extends StatefulWidget {
  const PaymentDestinationSelector({
    super.key,
    required this.onNetworkChanged,
    this.initialNetwork,
  });

  final ValueChanged<MemberPaymentNetwork> onNetworkChanged;
  final MemberPaymentNetwork? initialNetwork;

  @override
  State<PaymentDestinationSelector> createState() =>
      _PaymentDestinationSelectorState();
}

class _PaymentDestinationSelectorState
    extends State<PaymentDestinationSelector> {
  MemberPaymentNetwork? _selectedNetwork;

  @override
  void initState() {
    super.initState();
    _selectedNetwork = widget.initialNetwork;
  }

  void _selectNetwork(MemberPaymentNetwork network) {
    setState(() {
      _selectedNetwork = network;
    });

    widget.onNetworkChanged(network);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode de paiement',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Sélectionnez le réseau Mobile Money que vous souhaitez utiliser.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: MemberPaymentNetwork.values
                  .map(
                    (network) => SizedBox(
                      width: isWide
                          ? (constraints.maxWidth - 24) / 3
                          : constraints.maxWidth,
                      child: _buildNetworkCard(context, network),
                    ),
                  )
                  .toList(),
            );
          },
        ),

        if (_selectedNetwork != null) ...[
          const SizedBox(height: 16),
          _buildSelectedNetwork(context),
        ],
      ],
    );
  }

  Widget _buildNetworkCard(BuildContext context, MemberPaymentNetwork network) {
    final theme = Theme.of(context);
    final isSelected = _selectedNetwork == network;

    return InkWell(
      onTap: () => _selectNetwork(network),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(network.icon, color: theme.colorScheme.primary),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                network.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedNetwork(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Réseau sélectionné : '
              '${_selectedNetwork!.label}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

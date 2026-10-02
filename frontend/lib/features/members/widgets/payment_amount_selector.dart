import 'package:flutter/material.dart';

class PaymentAmountSelector extends StatefulWidget {
  const PaymentAmountSelector({
    super.key,
    required this.onAmountChanged,
    this.initialAmount = 10,
  });

  final ValueChanged<double> onAmountChanged;
  final double initialAmount;

  @override
  State<PaymentAmountSelector> createState() => _PaymentAmountSelectorState();
}

class _PaymentAmountSelectorState extends State<PaymentAmountSelector> {
  static const List<double> _presetAmounts = [10, 20, 30, 40, 50];

  late double _selectedAmount;
  late final TextEditingController _customAmountController;

  bool _isCustomAmount = false;

  @override
  void initState() {
    super.initState();

    _selectedAmount = widget.initialAmount;

    _customAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _selectPreset(double amount) {
    setState(() {
      _selectedAmount = amount;
      _isCustomAmount = false;
      _customAmountController.clear();
    });

    widget.onAmountChanged(amount);
  }

  void _selectCustomAmount() {
    setState(() {
      _isCustomAmount = true;
    });

    final value = double.tryParse(_customAmountController.text.trim());

    if (value != null && value > 0) {
      _selectedAmount = value;
      widget.onAmountChanged(value);
    }
  }

  void _onCustomAmountChanged(String value) {
    final amount = double.tryParse(value.trim());

    if (amount == null || amount <= 0) {
      return;
    }

    setState(() {
      _selectedAmount = amount;
    });

    widget.onAmountChanged(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant de la contribution',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Choisissez le montant que vous souhaitez verser.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._presetAmounts.map(
                  (amount) => _buildAmountButton(context, amount, isWide),
                ),

                _buildCustomAmountButton(context, isWide),
              ],
            );
          },
        ),

        if (_isCustomAmount) ...[
          const SizedBox(height: 16),

          TextFormField(
            controller: _customAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: _onCustomAmountChanged,
            decoration: const InputDecoration(
              labelText: 'Montant personnalisé',
              hintText: 'Ex. 75',
              prefixText: '\$ ',
              prefixIcon: Icon(Icons.edit_outlined),
              border: OutlineInputBorder(),
            ),
          ),
        ],

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.payments_outlined, color: theme.colorScheme.primary),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant sélectionné',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '\$${_selectedAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountButton(BuildContext context, double amount, bool isWide) {
    final theme = Theme.of(context);

    final selected = !_isCustomAmount && _selectedAmount == amount;

    return SizedBox(
      width: isWide ? 110 : 92,
      child: OutlinedButton(
        onPressed: () => _selectPreset(amount),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.10)
              : null,
          side: BorderSide(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? theme.colorScheme.primary : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAmountButton(BuildContext context, bool isWide) {
    final theme = Theme.of(context);

    return SizedBox(
      width: isWide ? 130 : 120,
      child: OutlinedButton.icon(
        onPressed: _selectCustomAmount,
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('Autre'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: _isCustomAmount
              ? theme.colorScheme.primary.withValues(alpha: 0.10)
              : null,
          side: BorderSide(
            color: _isCustomAmount
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: _isCustomAmount ? 1.5 : 1,
          ),
        ),
      ),
    );
  }
}

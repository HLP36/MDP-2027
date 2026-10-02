import 'package:flutter/material.dart';

import '../widgets/payment_amount_selector.dart';
import '../widgets/payment_destination_selector.dart';

class MemberPaymentPage extends StatefulWidget {
  const MemberPaymentPage({super.key, required this.memberId, this.memberName});

  final String memberId;
  final String? memberName;

  @override
  State<MemberPaymentPage> createState() => _MemberPaymentPageState();
}

class _MemberPaymentPageState extends State<MemberPaymentPage> {
  double _amount = 10;

  MemberPaymentNetwork? _network;

  bool _isSubmitting = false;

  void _onAmountChanged(double amount) {
    setState(() {
      _amount = amount;
    });
  }

  void _onNetworkChanged(MemberPaymentNetwork network) {
    setState(() {
      _network = network;
    });
  }

  Future<void> _continuePayment() async {
    if (_amount <= 0) {
      _showMessage('Veuillez sélectionner un montant valide.');
      return;
    }

    if (_network == null) {
      _showMessage('Veuillez sélectionner un réseau de paiement.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    /*
     * IMPORTANT :
     * Cette étape ne déclenche pas encore le paiement réel.
     *
     * Le backend devra :
     * 1. créer le PaymentIntent ;
     * 2. déterminer la destination configurée ;
     * 3. envoyer/initialiser la transaction ;
     * 4. suivre son statut ;
     * 5. créer la Contribution après validation.
     *
     * Aucun numéro Mobile Money n'est conservé dans cette page.
     */

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    _showPaymentConfirmation();
  }

  void _showPaymentConfirmation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmation du paiement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.memberName != null) ...[
                Text(
                  widget.memberName!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
              ],
              Text('Montant : \$${_amount.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              Text('Réseau : ${_network!.label}'),
              const SizedBox(height: 16),
              const Text(
                'La transaction sera créée et traitée '
                'par le système de paiement.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                _showMessage(
                  'Le paiement sera connecté au service '
                  'Mobile Money lors de l’intégration API.',
                );
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payer une contribution')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  const SizedBox(height: 28),

                  PaymentAmountSelector(
                    initialAmount: _amount,
                    onAmountChanged: _onAmountChanged,
                  ),

                  const SizedBox(height: 32),

                  PaymentDestinationSelector(
                    initialNetwork: _network,
                    onNetworkChanged: _onNetworkChanged,
                  ),

                  const SizedBox(height: 32),

                  _buildPaymentSummary(context),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSubmitting ? null : _continuePayment,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward_outlined),
                      label: Text(
                        _isSubmitting ? 'Préparation...' : 'Continuer',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      'Les informations de paiement sont '
                      'traitées de manière sécurisée.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contribution MDP',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          widget.memberName == null
              ? 'Effectuez votre contribution mensuelle.'
              : 'Contribution de ${widget.memberName}.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            _buildSummaryRow(
              context,
              label: 'Montant',
              value: '\$${_amount.toStringAsFixed(2)}',
            ),

            const SizedBox(height: 10),

            _buildSummaryRow(
              context,
              label: 'Réseau',
              value: _network?.label ?? 'Non sélectionné',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../../shared/metrics/app_metrics.dart';

/// Componente com os campos de consulta: por CEP ou por endereço.
///
/// Só coleta o que o entregador digitou e avisa a página pelos callbacks;
/// quem valida e consulta é o controller/service.
class SearchForm extends StatefulWidget {
  const SearchForm({
    super.key,
    required this.onSearchCep,
    required this.onSearchAddress,
    this.enabled = true,
  });

  final ValueChanged<String> onSearchCep;
  final void Function({
    required String uf,
    required String city,
    required String street,
  })
  onSearchAddress;

  /// Falso enquanto uma consulta está em andamento.
  final bool enabled;

  @override
  State<SearchForm> createState() => _SearchFormState();
}

enum _SearchMode { cep, address }

class _SearchFormState extends State<SearchForm> {
  _SearchMode _mode = _SearchMode.cep;
  final _cep = TextEditingController();
  final _uf = TextEditingController();
  final _city = TextEditingController();
  final _street = TextEditingController();

  @override
  void dispose() {
    for (final c in [_cep, _uf, _city, _street]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus(); // fecha o teclado
    if (_mode == _SearchMode.cep) {
      widget.onSearchCep(_cep.text);
    } else {
      widget.onSearchAddress(
        uf: _uf.text,
        city: _city.text,
        street: _street.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_SearchMode>(
          segments: const [
            ButtonSegment(
              value: _SearchMode.cep,
              label: Text('Por CEP'),
              icon: Icon(Icons.pin_drop),
            ),
            ButtonSegment(
              value: _SearchMode.address,
              label: Text('Por endereço'),
              icon: Icon(Icons.signpost),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) =>
              setState(() => _mode = selection.first),
        ),
        const SizedBox(height: AppMetrics.spaceMd),
        if (_mode == _SearchMode.cep)
          TextField(
            key: const Key('cepField'),
            controller: _cep,
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            // Só números e hífen, até 9 caracteres ("01001-000").
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
              LengthLimitingTextInputFormatter(9),
            ],
            decoration: const InputDecoration(
              labelText: 'CEP',
              hintText: '00000-000',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          )
        else ...[
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  key: const Key('ufField'),
                  controller: _uf,
                  enabled: widget.enabled,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [LengthLimitingTextInputFormatter(2)],
                  decoration: const InputDecoration(
                    labelText: 'UF',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: AppMetrics.spaceSm),
              Expanded(
                child: TextField(
                  key: const Key('cityField'),
                  controller: _city,
                  enabled: widget.enabled,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Cidade',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppMetrics.spaceSm),
          TextField(
            key: const Key('streetField'),
            controller: _street,
            enabled: widget.enabled,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Rua (completa ou parte do nome)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
        const SizedBox(height: AppMetrics.spaceSm),
        FilledButton.icon(
          key: const Key('searchButton'),
          onPressed: widget.enabled ? _submit : null,
          icon: const Icon(Icons.search),
          label: const Text('Consultar'),
        ),
      ],
    );
  }
}

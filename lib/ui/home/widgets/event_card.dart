import 'dart:convert';

import 'package:eventoweb_secretaria_front/data/models/events/dto_evento.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {

  const EventCard({
    required this.evento, required this.onGerenciarClick, super.key,
  });
  
  final DTOEvento evento;
  final VoidCallback onGerenciarClick;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Logo/Image
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: Theme.of(context).canvasColor,
              image: evento.logotipo != null
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(evento.logotipo!)),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: evento.logotipo == null
                ? Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Theme.of(context).canvasColor,
                    ),
                  )
                : null,
          ),
          // Event Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nome,
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Inscription Period
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Inscrições:',
                  value:
                      '${dateFormat.format(evento.dataInicialInscricao)} a ${dateFormat.format(evento.dataFinalInscricao)}',
                ),
                const SizedBox(height: 8),
                // Event Period
                _InfoRow(
                  icon: Icons.event,
                  label: 'Realização:',
                  value:
                      '${dateFormat.format(evento.dataInicialRealizacao)} a ${dateFormat.format(evento.dataFinalRealizacao)}',
                ),
                const SizedBox(height: 16),
                // Inscription Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onGerenciarClick,
                    child: const Text('Gerenciar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                TextSpan(
                  text: ' $value',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
}

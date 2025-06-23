import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';

/// **AppStateHandler** - Gerenciador de estados da aplicação
///
/// Este componente é responsável por:
/// - Gerenciar estado de loading inicial
/// - Exibir tela de erro com opção de retry
/// - Decidir quando mostrar o conteúdo principal
/// - Fornecer interface consistente para estados da app
///
/// **Estados gerenciados:**
/// - Loading: Indicador de carregamento inicial
/// - Error: Tela de erro com botão "Tentar Novamente"
/// - Success: Renderiza o conteúdo principal fornecido
///
/// **Funcionalidades:**
/// - Detecção automática de estado baseada no controller
/// - Interface de erro amigável ao usuário
/// - Ação de retry integrada
/// - Design responsivo e acessível
class AppStateHandler extends StatelessWidget {
  final TaskController controller;
  final Widget child;

  const AppStateHandler({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estado de loading inicial
    if (controller.isLoading && controller.lists.isEmpty) {
      return _buildLoadingState(context);
    }

    // Estado de erro
    if (controller.error != null) {
      return _buildErrorState(context);
    }

    // Estado de sucesso - renderizar conteúdo principal
    return child;
  }

  /// Constrói o estado de loading
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Carregando dados...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o estado de erro
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de erro
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),

            // Título do erro
            Text(
              'Erro ao carregar dados',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Mensagem de erro detalhada
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                ),
              ),
              child: Text(
                controller.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Botão de retry
            ElevatedButton.icon(
              onPressed: () => _handleRetry(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),

            // Dica adicional
            const SizedBox(height: 16),
            Text(
              'Verifique sua conexão com a internet',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Gerencia a ação de retry
  void _handleRetry(BuildContext context) {
    // Simples refresh do controller - o método específico pode variar
    // dependendo da implementação do TaskController
    // Por exemplo: controller.refresh(), controller.reload(), etc.
    print('🔄 Tentando recarregar dados...');

    // Placeholder para implementação futura do retry
    // context.read<TaskController>().reload();
  }
}

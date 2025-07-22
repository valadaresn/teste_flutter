# Sistema de Temas do Sidebar - Samsung Notes

Este documento explica como usar o novo sistema de temas do painel lateral (sidebar) que inclui o tema Samsung Notes.

## Funcionalidades Implementadas

### ✅ Etapa 1: Configuração do Sistema de Temas
- Enum `SidebarTheme` com valores `defaultTheme` e `samsungNotes`
- Gerenciamento de estado no `ThemeProvider`
- Persistência da preferência do usuário

### ✅ Etapa 2: Componentes Estilizados
- `SamsungSidebarTheme`: Constantes de design
- `SamsungListItem`: Widget de item individual
- `SamsungSectionHeader`: Cabeçalho de seções
- `SamsungSidebar`: Sidebar principal

### ✅ Etapa 3: Integração
- Integração no `TaskManagementScreen`
- Tela de configurações atualizada
- Widget de alternância rápida

## Como Usar

### 1. Alternar Tema nas Configurações

```dart
// Navegar para as configurações
Navigator.of(context).pushNamed('/settings');

// A nova seção "Tema do Painel Lateral" permite escolher entre:
// - Padrão: Painel colorido com emojis
// - Samsung Notes: Painel minimalista e clean
```

### 2. Usar o Widget de Alternância Rápida

```dart
import 'package:flutter/material.dart';
import '../widgets/common/sidebar_theme_toggle.dart';

// Adicionar na AppBar ou em um menu
AppBar(
  actions: [
    SidebarThemeToggle(), // Permite alternar rapidamente
  ],
)
```

### 3. Verificar Tema Atual Programaticamente

```dart
// Obter o tema atual
final currentTheme = Provider.of<ThemeProvider>(context).sidebarTheme;

// Alterar tema programaticamente
await Provider.of<ThemeProvider>(context, listen: false)
    .setSidebarTheme(SidebarTheme.samsungNotes);
```

## Estrutura dos Arquivos

```
lib/features/task_management/
├── themes/
│   ├── app_theme.dart                 # Enum SidebarTheme
│   └── theme_provider.dart            # Gerenciamento de estado
├── widgets/
│   ├── layouts/
│   │   └── samsung_style/
│   │       ├── samsung_sidebar_theme.dart    # Constantes de design
│   │       ├── samsung_list_item.dart        # Widget de item
│   │       ├── samsung_section_header.dart   # Cabeçalho de seção
│   │       ├── samsung_sidebar.dart          # Sidebar principal
│   │       └── index.dart                    # Exports
│   └── common/
│       └── sidebar_theme_toggle.dart  # Widget de alternância
├── screens/
│   ├── task_management_screen.dart    # Integração principal
│   └── settings_screen.dart           # Configurações
```

## Características do Tema Samsung Notes

- **Visual minimalista**: Cores sutis (#F5F5F5, #E8E8E8)
- **Tipografia clean**: Fonte leve (14px, FontWeight.w400)
- **Seleção sutil**: Fundo cinza claro para itens ativos
- **Hierarquia visual**: Recuo de 16px para itens aninhados
- **Ícones outline**: Material Design outline icons
- **Contadores discretos**: Números em cinza claro (#8E8E8E)

## Próximos Passos (Opcional)

1. **Animações de transição** entre temas
2. **Temas adicionais** (ex: Dark Mode Samsung Notes)
3. **Personalização avançada** de cores
4. **Importação/exportação** de configurações de tema

## Exemplo de Uso Completo

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ... outros providers
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'App com Temas de Sidebar',
            theme: ThemeData.light(),
            home: TaskManagementScreen(),
            routes: {
              '/settings': (context) => SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
```

---

**Implementado com sucesso!** 🎉

O sistema de temas do sidebar está funcionando e permite alternar entre o tema padrão (colorido) e o tema Samsung Notes (minimalista) de forma seamless.

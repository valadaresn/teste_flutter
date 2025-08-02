# Configurações de Build - Firebase Otimizado
# Este arquivo contém configurações para reduzir o tamanho da pasta build

# Para reduzir tamanho do Firebase SDK:
# 1. Usar apenas os módulos necessários
# 2. Configurar release builds menores
# 3. Limpeza automática de arquivos temporários

# Comandos recomendados:
# flutter build windows --release
# flutter clean (após desenvolvimento)

# Configurações do CMake para Windows (adicionar ao CMakeLists.txt):
# set(CMAKE_BUILD_TYPE Release)
# set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")

# Para desenvolvimento, usar:
# flutter run -d windows (não gera build grande)
# flutter build windows --debug (apenas quando necessário)

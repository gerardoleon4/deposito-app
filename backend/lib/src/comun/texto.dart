const _sinAcento = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', //
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', //
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', //
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', //
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', //
  'ñ': 'n',
};

/// Texto en minúsculas y sin acentos, para búsquedas: "Pacífico" → "pacifico".
String normalizarBusqueda(String texto) {
  final b = StringBuffer();
  for (final c in texto.toLowerCase().split('')) {
    b.write(_sinAcento[c] ?? c);
  }
  return b.toString().trim();
}

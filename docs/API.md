# Contrato de la API

Este documento es el acuerdo entre `backend/` y `app/`. Ningún endpoint se programa sin estar primero aquí.

Los cambios a este archivo se hacen por pull request con la etiqueta `contrato`.

## Convenciones

| Tema | Regla |
| --- | --- |
| Prefijo | Las rutas empiezan con `/api/v1`, salvo `/salud` |
| Formato | JSON en UTF-8 |
| Nombres | En español, sin acentos, en `camelCase`: `precioCaja`, `piezasPorCaja` |
| Dinero | Entero en centavos: $42.50 se manda como `4250` |
| Fechas | ISO 8601 en UTC: `2026-10-02T18:30:00Z` |
| Existencias | Siempre en piezas. Las cajas son solo visuales |
| Errores | `{ "error": { "codigo": "stock_insuficiente", "mensaje": "..." } }` |

Códigos HTTP: `200` OK, `201` creado, `400` datos inválidos, `401` no autorizado, `404` no existe, `409` conflicto, `500` error del servidor.

## Endpoints

### Salud

`GET /salud`

Comprueba que el servidor responde.

- Respuesta `200`: el texto `ok`.

## Pendientes

Se documentarán aquí, en este orden: terminales, productos, envases, pedidos, ventas, caja, alertas, reportes, ajustes, respaldo y WebSocket.

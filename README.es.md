# 🍽 HomeMealsApp

🌍 Available in: [English](README.md)

**HomeMealsApp** es una aplicación móvil para la planificación de comidas, gestión de recetas, control de inventario de ingredientes y generación de listas de compra. La app permite a los usuarios organizar sus comidas diarias, asegurarse de tener los ingredientes necesarios y facilitar la compra de productos faltantes.

> ⚠️ **Nota:** HomeMealsApp requiere una API para su funcionamiento, la cual actualmente no es pública por razones de seguridad.


## 🛠️ Requisitos del sistema

- **iOS 17.5 o superior**: La aplicación está diseñada para dispositivos que ejecuten iOS 14.0 o versiones posteriores.
- **Xcode 15.4 o superior**: Necesario para compilar y ejecutar el proyecto.
- **Swift 5.10 o superior**: El proyecto está desarrollado en la versión Swift por defecto de Xcode.

---

## 🚀 Características

- 📅 **Planificación de comidas**: Organiza las comidas del día en un calendario interactivo.
- 📝 **Gestión de recetas**: Guarda, consulta y administra recetas personalizadas.
- 🏠 **Inventario de ingredientes**: Registra los ingredientes que tienes en casa y mantén tu despensa organizada.
- 🛒 **Listas de compra inteligentes**: Genera listas de compra basadas en las recetas planificadas y los ingredientes faltantes.
- 🔐 **Autenticación de usuarios**: Registro e inicio de sesión con credenciales o Sign in with Apple.
<!--- ☁️ **Sincronización en la nube**: Los datos se almacenan de forma segura en el servidor.  -->

---

## 📱 Tecnologías utilizadas

- **Swift** y **SwiftUI** para la interfaz de usuario.
- **SwiftData** para la persistencia de datos local.
- **Vapor** (Backend en Swift) para la gestión del servidor y la base de datos.
- **AuthenticationServices** para el inicio de sesión con Apple.
- **Async/Await** para la gestión de estados y datos asíncronos.

---

## 🔧 Instalación y configuración

### 📦 Clonar el repositorio

```bash
git clone https://github.com/antjiminf/HomeMealsApp.git
cd HomeMealsApp
```

### 📲 Ejecutar la aplicación

1. Abre `HomeMeals.xcodeproj` en Xcode.
2. Asegúrate de tener seleccionado un simulador o dispositivo real.
3. Compila y ejecuta (`Cmd + R`).

---

## 🔑 Configuración de autenticación

Para habilitar el inicio de sesión con Apple, asegúrate de:
1. Activar la capacidad **Sign in with Apple** en el proyecto.
2. Configurar los **App IDs** en el portal de Apple Developer.

---

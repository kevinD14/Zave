import 'package:flutter/material.dart';

/// Pantalla que muestra los Términos y Condiciones y la Política de Privacidad
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y condiciones'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: const Text(
            _termsAndPrivacyText,
            style: TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}

/// Texto de los términos y política, definido aparte para mayor limpieza
const String _termsAndPrivacyText = '''
TÉRMINOS Y CONDICIONES DE USO

Este servicio realiza respaldos y restauraciones de tus datos mediante tu cuenta de Google Drive. Al iniciar sesión, aceptas los siguientes términos:

1. Tus datos serán almacenados de forma segura y privada.

2. El respaldo sobrescribirá los datos previamente guardados en la nube.

3. La restauración eliminará los datos locales actuales y los reemplazará con los respaldados.

4. No nos hacemos responsables por pérdidas causadas por fallos ajenos al sistema.

5. Puedes cerrar sesión en cualquier momento desde la aplicación.

Al usar esta función, aceptas estos términos.


POLÍTICA DE PRIVACIDAD

En Zave, valoramos tu privacidad y estamos comprometidos con protegerla. Esta política describe cómo gestionamos los datos que recopilamos y cómo interactuamos con los servicios de terceros, como Firebase y Google Drive.

1. Información que recopilamos
No almacenamos ni recolectamos información personal en nuestros propios servidores. Toda la información que se maneja en la app es gestionada a través de tu cuenta personal de Google y se almacena directamente en Google Drive, un servicio proporcionado por Google.

2. Uso de Firebase y Google Drive
La app utiliza Firebase, una plataforma de Google, para facilitar la autenticación de usuarios y la conexión con los servicios de Google. Los datos que compartes con Google al iniciar sesión o realizar acciones en la app (como subir o restaurar archivos) son gestionados y almacenados exclusivamente en tu cuenta personal de Google Drive.

Google Drive se encarga del almacenamiento y la gestión de tus datos, y solo tú tienes control sobre los mismos. La app no tiene acceso a tus archivos o datos almacenados en Google Drive, excepto aquellos que seleccionas explícitamente para cargar o restaurar a través de la app.

3. Acceso y control de tus datos
Tienes control total sobre los datos que decides subir o restaurar desde tu cuenta de Google Drive. La app solo interactúa con los archivos seleccionados y no recopila ni almacena información fuera de lo que el usuario elige compartir durante el uso de las funciones de respaldo o restauración.

4. Autenticación y Seguridad
La autenticación de usuarios se maneja mediante el sistema de autenticación de Firebase y Google. Utilizamos OAuth 2.0 para garantizar que solo los usuarios autorizados puedan acceder a su cuenta de Google Drive a través de nuestra app. La app no almacena tus credenciales ni otra información personal. Los datos transferidos entre nuestra app y Google Drive están cifrados para proteger tu privacidad y seguridad.

5. Servicios de terceros
Al utilizar Google Drive para almacenar datos, se aplica la Política de Privacidad de Google. Te recomendamos leerla para comprender cómo Google maneja tus datos. Ten en cuenta que, aunque la app no almacena tus datos en sus propios servidores, tus datos son gestionados a través de Google y están sujetos a las políticas de privacidad y condiciones de uso de Google.

6. Cambios en esta Política de Privacidad
Nos reservamos el derecho de modificar esta Política de Privacidad en cualquier momento. Si realizamos cambios, te notificaremos a través de un aviso dentro de la app o por otros medios, según corresponda. Te recomendamos revisar esta política periódicamente para estar al tanto de cómo protegemos tu información.
''';

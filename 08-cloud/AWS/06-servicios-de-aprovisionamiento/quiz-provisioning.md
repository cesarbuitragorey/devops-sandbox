# Quiz de DevOps Bootcamp — AWS Provisioning

Preguntas, respuestas correctas y explicaciones. Material de repaso para el módulo 6 (Servicios de Aprovisionamiento).

---

### 1. What are the limitations of AWS CloudFormation?
- Can only manage resources within a single region
- Templates must be valid JSON or YAML
- You can create only 20 stacks per region
- Stacks can only be created or updated one at a time
- No posibility to launch non-AWS resources

**Respuesta correcta:** You can create only 20 stacks per region
**Por qué:** Es la limitación real por defecto (ajustable vía soporte de AWS). Las demás son falsas: puedes tener stacks en múltiples regiones (y StackSets despliega across regiones/cuentas), el formato JSON/YAML es un requisito no una limitación, puedes crear/actualizar múltiples stacks en paralelo, y sí soporta custom resources vía Lambda y el CloudFormation Registry.

### 2. Which AWS service has build-in integration with CloudFormation for CI/CD of templates?
- AWS CodeCommit
- AWS Lambda
- AWS CodePipeline
- AWS Simulation run
- AWS Managed Jenkins service

**Respuesta correcta:** AWS CodePipeline
**Por qué:** CodePipeline tiene integración nativa con CloudFormation para automatizar build, testing y despliegue de templates. CodeCommit es solo un repositorio Git, Lambda es cómputo serverless, y las otras dos opciones no son servicios reales de AWS.

### 3. What service or feature identifies stack resources changed outside of CloudFormation management?
- AWS Managed service
- AWS Config
- AWS CloudFormation drift detection
- AWS Recording Configuration

**Respuesta correcta:** AWS CloudFormation drift detection
**Por qué:** Compara el estado actual real de los recursos contra lo que el template espera, identificando cambios fuera de banda. AWS Config rastrea configuración a lo largo del tiempo pero no está diseñado específicamente para re-sincronizar con la definición del stack; las otras dos opciones no existen como tal.

### 4. Can CloudFormation bootstrap software at stack creation?
- No, CloudFormation doesn't support installing software at stack creation
- Yes, by opening an AWS Support ticket
- Yes. AWS CloudFormation provides a set of application bootstrapping scripts that enable you to install packages, files, and services on your EC2 instances
- Yes, integrado con Systems Manager

**Respuesta correcta:** Yes. AWS CloudFormation provides a set of application bootstrapping scripts that enable you to install packages, files, and services on your EC2 instances
**Por qué:** Se refiere a los helper scripts (`cfn-init`, `cfn-signal`, `cfn-hup`, `cfn-get-metadata`), invocados desde `UserData` y que leen `AWS::CloudFormation::Init`. Es una capacidad nativa self-service, no requiere ticket de soporte; SSM Automation es más para mantenimiento continuo post-despliegue, no el mecanismo estándar de bootstrap al crear el stack.

### 5. Which CloudFormation function is used for cross-stack references to export resources from one stack to another?
- Fn::GetAtt
- Fn::Ref
- Fn::ImportValue
- Fn::ExportValue

**Respuesta correcta:** Fn::ImportValue
**Por qué:** Se usa para importar (referenciar) un valor exportado por otro stack; el export se define en el campo `Export` dentro de `Outputs`. `Fn::GetAtt` obtiene un atributo de un recurso dentro del mismo stack, `Ref` (no "Fn::Ref") referencia dentro del mismo stack, y `Fn::ExportValue` no existe.

### 6. Which of the AWS CloudFormation template sections is/are required?
- Resources
- Parameters
- Metadata
- AWSTemplateFormatVersion
- All above

**Respuesta correcta:** Resources
**Por qué:** Es la única sección obligatoria — debe declarar al menos un recurso AWS. Todas las demás (Parameters, Metadata, AWSTemplateFormatVersion) son opcionales.

### 7. By default, with what permissions will AWS CloudFormation stack operations perform?
- The permissions of the user performing the operation
- Root AWS user
- AWS CloudFormation service role
- Doesn't use permission checks

**Respuesta correcta:** The permissions of the user performing the operation
**Por qué:** Por defecto, sin un service role especificado, CloudFormation usa las credenciales/permisos de la entidad IAM que ejecuta la acción. Un service role es válido y configurable, pero no es el comportamiento por defecto; sí requiere y evalúa permisos IAM (no los omite).

### 8. A dev team wants isolated test environments, easy to bring up and down. How can this best be achieved?
- Use CloudFormation templates to provision the resources
- Auto Scaling groups
- IAM Policies
- Custom script

**Respuesta correcta:** Use CloudFormation templates to provision the resources
**Por qué:** Defines toda la infraestructura en un template, creas el stack cuando lo necesitas, y lo eliminas cuando termines — repetible y sin recursos huérfanos. Auto Scaling está pensado para escalar instancias EC2 (no levantar/destruir entornos completos), IAM Policies solo controla permisos, y un script custom es menos robusto sin garantías de manejo de dependencias/rollback.

### 9. Standard web-tier app, easy-to-manage highly-scalable hosting, sin gestionar provisioning/deployment. ¿Qué servicio usar?
- AWS Elastic Beanstalk
- AWS CloudFormation
- AWS OpsWorks
- AWS CodeDeploy

**Respuesta correcta:** AWS Elastic Beanstalk
**Por qué:** Subes tu código y AWS gestiona automáticamente la infraestructura subyacente sin necesidad de personalizar el proceso. CloudFormation es IaC de bajo nivel (requiere gestionar cada recurso explícitamente), OpsWorks usa Chef/Puppet para quienes sí quieren personalizar el provisioning, y CodeDeploy solo despliega código a instancias existentes.

### 10. Which of the formats are valid for an AWS CloudFormation template?
- YAML y JSON
- XML
- Markdown
- CSV

**Respuesta correcta:** YAML y JSON
**Por qué:** Son los dos únicos formatos válidos y soportados nativamente por CloudFormation. XML no está soportado, Markdown es formato de documentación y CSV es tabular, sin la estructura jerárquica necesaria.

### 11. What are the benefits of AWS CloudFormation? (all apply)
- No crear recursos manualmente
- Cambios revisados por código
- Destruir/recrear infraestructura al vuelo
- Programación declarativa
- Stacks separados por propósito
- All of above are true

**Respuesta correcta:** All of above are true
**Por qué:** Todas las opciones listadas son beneficios reales y válidos de CloudFormation.

### 12. ¿Qué pasa cuando un recurso de un stack CloudFormation no puede crearse exitosamente, con parámetros por defecto?
- CloudFormation automatically deletes all resources if there is a failure during creation or updating
- Creates or updates regardless if operations succeed or not
- Reverts to the last known stable configuration
- Deletes failed resources and proceeds

**Respuesta correcta:** CloudFormation automatically deletes all resources if there is a failure during creation or updating
**Por qué:** Con `ON_FAILURE: ROLLBACK` (default), si falla la creación de cualquier recurso, CloudFormation elimina automáticamente todos los recursos ya creados en ese intento — no continúa parcialmente ni ignora el fallo. "Reverts to the last known stable configuration" aplicaría más a un update fallido; en una creación no hay configuración previa a la cual volver.

### 13. Could the data be saved after a CloudFormation stack is deleted?
- You can specify resources that should be preserved and not deleted when the stack is deleted
- No, all data are lost when the stack is deleted
- CloudFormation doesn't allow deletion policies
- Only possible via AWS Support

**Respuesta correcta:** You can specify resources that should be preserved and not deleted when the stack is deleted
**Por qué:** Se logra con el atributo `DeletionPolicy` (`Retain`, `Snapshot`, `Delete`) definido a nivel de recurso en el template — es un atributo nativo, self-service, no requiere soporte.

### 14. What features do change sets for CloudFormation stacks offer you? (2 correctas)
- Change sets allow you to preview how proposed changes might impact your running resources
- You can proceed with updates when you've confirmed that all the changes are as intended
- Monitor and detect drift in nested stacks
- Allow you to import resources from nested stacks

**Respuesta correcta:** Change sets allow you to preview how proposed changes might impact your running resources; You can proceed with updates when you've confirmed that all the changes are as intended
**Por qué:** Un change set genera un resumen de cambios propuestos antes de ejecutar el update real; solo tras revisarlo decides si ejecutarlo. Detectar drift en nested stacks es función de drift detection (independiente de change sets), e importar recursos es una funcionalidad separada (resource import).

### 15. Diferencias entre AWS Elastic Beanstalk y AWS CloudFormation (3 correctas)
- Elastic Beanstalk: fácil de usar para desplegar y escalar apps web en varios lenguajes
- CloudFormation: provee un lenguaje común para describir y provisionar toda la infraestructura
- Elastic Beanstalk: integrado con developer tools para desplegar y correr apps fácilmente
- Beanstalk es más como IaC y CloudFormation es PaaS
- Con CloudFormation no necesitas experiencia en la nube
- Beanstalk se enfoca en infraestructura, no en la app

**Respuesta correcta:** Elastic Beanstalk: fácil de usar para desplegar y escalar apps web en varios lenguajes; CloudFormation: provee un lenguaje común para describir y provisionar toda la infraestructura; Elastic Beanstalk: integrado con developer tools para desplegar y correr apps fácilmente
**Por qué:** Son descripciones textuales precisas según la documentación oficial de AWS de cada servicio. Las otras tres están invertidas: CloudFormation es IaC y Beanstalk es PaaS (no al revés); la descripción de "no necesitas experiencia en la nube" corresponde a Beanstalk, no a CloudFormation; y Beanstalk se enfoca en la app (abstrayendo la infraestructura), no al revés.

### 16. What options of deploying CloudFormation templates are available?
- Using the console to input parameters
- Using the AWS API
- Using the AWS CLI
- Using the Cloud Deploy service
- All of above are true

**Respuesta correcta:** All of above are true
**Por qué:** Usar la consola, la API de AWS y la AWS CLI son todos métodos válidos y reales para desplegar templates. "Cloud Deploy service" es un distractor con nombre ambiguo (no es un servicio real de AWS), pero al agrupar todas bajo "All of above", esa es la respuesta esperada dado que las otras tres opciones sí son correctas.

### 17. What are the specifics of CloudFormation? (2 correctas)
- Templates could be uploaded to S3 and then referenced in CloudFormation
- Stacks are identified by a name
- Se puede editar un template existente sin reupload
- Eliminar un stack no elimina todos los recursos, hay que hacerlo manualmente

**Respuesta correcta:** Templates could be uploaded to S3 and then referenced in CloudFormation; Stacks are identified by a name
**Por qué:** Puedes almacenar templates en un bucket S3 y referenciarlos por URL; cada stack se identifica de forma única por su nombre. Es falso que puedas actualizar sin reproporcionar la definición completa del template, y por defecto sí se eliminan todos los recursos al eliminar el stack (salvo `DeletionPolicy: Retain`/`Snapshot`).

### 18. IaC: dos enfoques (imperativo vs declarativo). Elegir declaraciones verdaderas (2 correctas)
- Imperativo: especifica los pasos exactos y el sistema no se desvía
- Declarativo: solo defines el requerimiento final, y la herramienta decide los pasos
- Imperativo: solo defines el requerimiento final
- Declarativo: especifica los pasos exactos

**Respuesta correcta:** Imperativo: especifica los pasos exactos y el sistema no se desvía; Declarativo: solo defines el requerimiento final, y la herramienta decide los pasos
**Por qué:** Imperativo = tú especificas el "cómo" (pasos exactos); declarativo = tú especificas el "qué" (resultado final), y la herramienta decide el "cómo". CloudFormation es un ejemplo de herramienta declarativa. Las otras dos opciones están invertidas respecto a estas definiciones.

### 19. Disaster recovery: recrear los mismos recursos en otra región usando templates de código. ¿Qué servicio usar?
- CloudFormation
- CodeDeploy
- Elastic Beanstalk
- CodeBuild

**Respuesta correcta:** CloudFormation
**Por qué:** Ideal para DR multi-región: defines la infraestructura como código y despliegas el mismo template en otra región para recrear rápida y consistentemente los mismos recursos. CodeDeploy solo despliega código de aplicación a instancias existentes, Beanstalk no ofrece el mismo nivel de control preciso y repetible, y CodeBuild es un servicio de CI para compilar/testear código, no para provisionar infraestructura.

### 20. What benefits can we gain by using automation to manage our infrastructure? (4 correctas)
- Repeatability
- Reliability
- Scalability
- Auditing and change management
- Hard to create

**Respuesta correcta:** Repeatability; Reliability; Scalability; Auditing and change management
**Por qué:** Repetibilidad (recrear la misma infraestructura sin variaciones), fiabilidad (menos error humano), escalabilidad (provisioning rápido según demanda), y auditoría/control de cambios (infraestructura como código versionada y rastreable). "Hard to create" es una desventaja, no un beneficio.

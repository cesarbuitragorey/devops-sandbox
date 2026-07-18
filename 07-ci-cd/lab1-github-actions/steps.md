Checklist para commits manuales (multi-cuenta)
Antes de cualquier git push, valida estos 3 puntos en la carpeta del repo:

1. ¿Qué remote tiene este repo?


git remote -v
Debe mostrar git@github.com-cesarbuitragorey:cesarbuitragorey/devops-sandbox.git. Si un día ves https://github.com/... o un alias distinto, alguien (o algún tool) lo cambió — corrígelo antes de seguir.

2. ¿Qué identidad de autor va a quedar en el commit?


git config user.name
git config user.email
Para este repo debe ser cesarbuitragorey / cesar.buitrago.rey@gmail.com (ya quedó seteado localmente, solo para este repo).

3. ¿Con qué llave SSH vas a autenticar el push?


ssh -T git@github.com-cesarbuitragorey
Debe responder Hi cesarbuitragorey! You've successfully authenticated.... Si responde con otro usuario, el alias/llave está mal.

Flujo normal de commit:


git status                     # revisa qué se va a incluir
git add <archivos específicos> # nunca "git add ." a ciegas
git commit -m "mensaje claro"
git push origin main
Para una cuenta nueva en el futuro, el patrón se repite:


ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_<alias> -C "correo@ejemplo.com"
# agregar entrada en ~/.ssh/config con Host github.com-<alias>
# agregar la .pub en github.com/settings/ssh/new de esa cuenta
# remote: git@github.com-<alias>:<usuario>/<repo>.git
Sobre la expo: dado que el pipeline corre en runners efímeros de GitHub (no algo visible "en vivo" fuera de la UI), para tu presentación te recomiendo mostrar: el diagrama del README → el workflow YAML → un push en vivo → la pestaña Actions con los steps expandidos mostrando minikube service list y la URL expuesta. Puedo ayudarte a preparar ese guion cuando tengamos el pipeline en verde.
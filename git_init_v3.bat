@echo off
REM ============================================================================
REM Script Git Init v3 - Synchronisation intelligente local/distant
REM Gere automatiquement les depots distants vierges (avec README) et locaux
REM ============================================================================

REM --- 1. Verifications ---
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Git n'est pas installe ou pas dans le PATH.
    pause
    exit /b 1
)

REM --- 2. Demande de l'URL du depot distant ---
echo.
echo ============================================================================
echo Configuration du depot Git
echo ============================================================================
echo.
set /p REMOTE_URL="URL du depot distant (ex: https://github.com/user/repo.git) : "

if not defined REMOTE_URL (
    echo [ERREUR] URL non fournie. Operation annulee.
    pause
    exit /b 1
)

REM --- 3. Initialisation si necessaire ---
if not exist ".git" (
    echo.
    echo [INFO] Initialisation du depot Git local...
    git init
    git branch -M main
) else (
    echo.
    echo [INFO] Depot Git deja initialise.
)

REM --- 4. Configuration du remote (si pas deja fait) ---
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Ajout du remote 'origin'...
    git remote add origin %REMOTE_URL%
) else (
    echo [INFO] Remote 'origin' deja configure.
    REM Mise a jour de l'URL au cas ou
    git remote set-url origin %REMOTE_URL%
)

REM --- 5. Sauvegarde du travail local (si fichiers non commites) ---
echo.
echo [INFO] Verification de l'etat local...

REM Verifie s'il y a des fichiers non commites
git status --porcelain >nul 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('git status --porcelain ^| find /c /v ""') do set CHANGES=%%i
) else (
    set CHANGES=0
)

if %CHANGES% gtr 0 (
    echo [INFO] Fichiers non commites detectes. Sauvegarde en cours...
    git add .
    git commit -m "WIP: Sauvegarde automatique avant sync" >nul 2>&1
    echo [OK] Travail local sauvegarde.
)

REM --- 6. Recuperation du depot distant ---
echo.
echo [INFO] Recuperation du depot distant...
git fetch origin >nul 2>&1

REM --- 7. Verification si la branche main existe sur le distant ---
git ls-remote --heads origin main >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Branche 'main' absente sur le distant. Premier push...
    git push -u origin main
    echo [OK] Depot local pousse vers le distant.
) else (
    REM La branche main existe sur le distant
    echo [INFO] Branche 'main' detectee sur le distant.
    
    REM Verifie si on a des commits locaux
    git rev-parse HEAD >nul 2>&1
    if %errorlevel% neq 0 (
        REM Pas de commits locaux, on pull simplement
        echo [INFO] Aucun commit local. Recuperation du distant...
        git pull origin main
        echo [OK] Depot distant recupere.
    ) else (
        REM On a des commits locaux ET distants, fusion necessaire
        echo [INFO] Fusion du travail local avec le distant...
        
        REM Tentative de pull avec fusion automatique
        git pull origin main --allow-unrelated-histories --no-edit >nul 2>&1
        
        if %errorlevel% neq 0 (
            REM Conflit detecte
            echo [ATTENTION] Conflits detectes lors de la fusion.
            echo.
            echo Options:
            echo   1. Garder le travail LOCAL (ecrase le distant)
            echo   2. Garder le travail DISTANT (ecrase le local)
            echo   3. Annuler et resoudre manuellement
            echo.
            set /p CHOICE="Votre choix (1/2/3) : "
            
            if "!CHOICE!"=="1" (
                git merge --abort >nul 2>&1
                git push -u origin main --force
                echo [OK] Travail local pousse (force).
            ) else if "!CHOICE!"=="2" (
                git merge --abort >nul 2>&1
                git reset --hard origin/main
                echo [OK] Travail distant recupere (force).
            ) else (
                git merge --abort >nul 2>&1
                echo [INFO] Fusion annulee. Resolvez manuellement avec:
                echo   git pull origin main --allow-unrelated-histories
                pause
                exit /b 1
            )
        ) else (
            REM Fusion reussie
            echo [OK] Fusion reussie.
            git push -u origin main
            echo [OK] Changements pousses vers le distant.
        )
    )
)

REM --- 8. Fin ---
echo.
echo ============================================================================
echo [SUCCES] Synchronisation terminee !
echo ============================================================================
echo.
echo Votre depot est pret. Vous pouvez maintenant:
echo   - Travailler normalement
echo   - Faire des commits: git add . ^&^& git commit -m "message"
echo   - Pousser vos changements: git push
echo.
pause

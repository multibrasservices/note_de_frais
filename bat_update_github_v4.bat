@echo off
setlocal enabledelayedexpansion
REM ============================================================================
REM Script Git Update v4 - Add, Commit, Push intelligent
REM Gere automatiquement la synchronisation avec verification et pull
REM ============================================================================

echo.
echo ============================================================================
echo    Assistant de Commit et Push pour GitHub
echo ============================================================================
echo.

REM --- 1. Verification de la branche ---
for /f %%i in ('git branch --show-current 2^>nul') do set current_branch=%%i

if not defined current_branch (
    echo [ERREUR] Impossible de determiner la branche actuelle.
    echo Etes-vous dans un depot Git ?
    pause
    exit /b 1
)

echo [INFO] Branche actuelle : %current_branch%
echo.

REM --- 2. Verification des changements ---
echo [INFO] Verification des changements...

git status --porcelain >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Impossible de verifier l'etat du depot.
    pause
    exit /b 1
)

for /f %%i in ('git status --porcelain ^| find /c /v ""') do set CHANGES=%%i

if %CHANGES% equ 0 (
    echo [INFO] Aucun changement a commiter.
    echo.
    echo Voulez-vous quand meme synchroniser avec le distant ?
    echo.
    set /p DO_PULL="Tapez 'o' pour OUI ou 'n' pour NON : "
    if /i "!DO_PULL!"=="o" (
        goto pull_only
    ) else (
        echo [INFO] Operation annulee. Rien a faire.
        pause
        exit /b 0
    )
)

REM --- 3. Affichage des changements ---
echo.
echo [CHANGEMENTS DETECTES]
echo ----------------------------------------------------------------------------
git status --short
echo ----------------------------------------------------------------------------
echo.

REM --- 4. Ajout des fichiers ---
echo [INFO] Ajout de tous les fichiers...
git add .
echo.

REM --- 5. Message de commit ---
echo [COMMIT]
echo.
echo Entrez le message de commit (ou appuyez sur Entree pour message auto) :
set /p commit_message=""

if not defined commit_message (
    REM Generation d'un message automatique base sur les fichiers modifies
    for /f "tokens=*" %%i in ('git diff --cached --name-only ^| head -n 3') do (
        if not defined files_list (
            set files_list=%%i
        ) else (
            set files_list=!files_list!, %%i
        )
    )
    
    if %CHANGES% gtr 3 (
        set commit_message=Update: !files_list! et %CHANGES% fichiers
    ) else (
        set commit_message=Update: !files_list!
    )
    
    echo [INFO] Message auto-genere : !commit_message!
)

REM --- 6. Commit ---
echo.
echo [INFO] Commit en cours...
git commit -m "!commit_message!"

if %errorlevel% neq 0 (
    echo [ERREUR] Echec du commit.
    pause
    exit /b 1
)
echo [OK] Commit reussi.
echo.

REM --- 7. Pull avant push (pour eviter les rejets) ---
:pull_only
echo [INFO] Synchronisation avec le distant...
git fetch origin >nul 2>&1

REM Verifie si la branche existe sur le distant
git ls-remote --heads origin %current_branch% >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Nouvelle branche locale. Premier push...
    goto push
)

REM Pull avec rebase pour garder un historique propre
git pull origin %current_branch% --rebase >nul 2>&1

if %errorlevel% neq 0 (
    echo.
    echo ============================================================================
    echo [CONFLIT DETECTE]
    echo ============================================================================
    echo.
    echo Le depot distant a des changements differents de votre travail local.
    echo.
    echo OPTION 1 : Forcer le push (RECOMMANDE si vous etes sur de votre travail)
    echo   - Votre travail local remplace completement le distant
    echo   - Les changements sur GitHub seront ecrases
    echo   - Rapide et simple
    echo.
    echo OPTION 2 : Resolution manuelle (pour experts Git)
    echo   - Le script s'arrete
    echo   - Vous devrez resoudre les conflits vous-meme
    echo   - Plus de controle mais plus complexe
    echo.
    set /p CONFLICT_CHOICE="Tapez 1 ou 2 puis Entree : "
    
    if "!CONFLICT_CHOICE!"=="1" (
        git rebase --abort >nul 2>&1
        echo [INFO] Rebase annule. Push force...
        git push origin %current_branch% --force
        if %errorlevel% equ 0 (
            echo [OK] Push force reussi.
        ) else (
            echo [ERREUR] Echec du push force.
            pause
            exit /b 1
        )
        goto end
    ) else (
        git rebase --abort >nul 2>&1
        echo [INFO] Operation annulee. Resolvez manuellement avec:
        echo   git pull origin %current_branch% --rebase
        echo   (resoudre les conflits)
        echo   git rebase --continue
        echo   git push
        pause
        exit /b 1
    )
) else (
    echo [OK] Synchronisation reussie.
)

REM --- 8. Push ---
:push
echo.
echo [INFO] Push vers origin %current_branch%...
git push --set-upstream origin %current_branch%

if %errorlevel% neq 0 (
    echo [ERREUR] Echec du push.
    echo.
    echo Voulez-vous forcer le push ? (o/n)
    set /p FORCE_PUSH="Reponse : "
    if /i "!FORCE_PUSH!"=="o" (
        git push origin %current_branch% --force
        if %errorlevel% equ 0 (
            echo [OK] Push force reussi.
        ) else (
            echo [ERREUR] Echec du push force.
            pause
            exit /b 1
        )
    ) else (
        echo [INFO] Push annule.
        pause
        exit /b 1
    )
) else (
    echo [OK] Push reussi.
)

REM --- 9. Fin ---
:end
echo.
echo ============================================================================
echo [SUCCES] Operation terminee !
echo ============================================================================
echo.
echo Votre depot est a jour sur GitHub.
echo Branche : %current_branch%
echo.
pause

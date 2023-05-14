@echo off

color 0f

:GetCompanyId
  set /P "companyId=Codigo da empresa: "
  goto :getInitialDate

:getInitialDate
  :: Configuração da verificação de formato
  setlocal EnableDelayedExpansion
  set i=0
  for %%a in (31 28 31 30 31 30 31 31 30 31 30 31) do (
      set /A i+=1
      set dpm[!i!]=%%a
  )
  
  :: Entrada da primeira data
  set /P "date1=Data inicial (DD-MM-AAAA): "

  :: Validações do formato da data
  if "%date1:~2,1%%date1:~5,1%" neq "--" goto :invalidDate
  for /F "tokens=1-3 delims=-" %%a in ("%date1%") do set "DD=%%a" & set "MM=%%b" & set "YYYY=%%c"
  ver > NUL
  set /A day=1%DD%-100, month=1%MM%-100, year=1%YYYY%-10000, leap=year%%4  2>NUL
  if errorlevel 1 goto :invalidDate
  if not defined dpm[%month%] goto :invalidDate
  if %leap% equ 0 set dpm[2]=29
  if %day% gtr !dpm[%month%]! goto :invalidDate
  if %day% lss 1 goto :invalidDate
  if %year% lss 1000 goto :invalidDate
  if %year% gtr 2099 goto :invalidDate

  :: Atribuição da data à variável
  set initialDate=%DD%-%MM%-%YYYY%
  set initialDateSQL=%YYYY%-%MM%-%DD%

  :: Encaminhamento para entrada da segunda data
  goto :getFinalDate
  
  :: Função de erro no formato da data
  :invalidDate
    cls
    for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
      set "DEL=%%a"
    )
    call :colorEcho cf "Formato de data incorreto! Tente novamente... "
    echo.
    goto :getInitialDate

:getFinalDate
  :: Configuração da verificação de formato
  setlocal EnableDelayedExpansion
  set i=0
  for %%a in (31 28 31 30 31 30 31 31 30 31 30 31) do (
      set /A i+=1
      set dpm[!i!]=%%a
  )

  :: Entrada da segunda data
  set /P "date2=Data final (DD-MM-AAAA): "

  :: Validações do formato da data
  if "%date2:~2,1%%date2:~5,1%" neq "--" goto :invalidDate
  for /F "tokens=1-3 delims=-" %%a in ("%date2%") do set "DD=%%a" & set "MM=%%b" & set "YYYY=%%c"
  ver > NUL
  set /A day=1%DD%-100, month=1%MM%-100, year=1%YYYY%-10000, leap=year%%4  2>NUL
  if errorlevel 1 goto :invalidDate
  if not defined dpm[%month%] goto :invalidDate
  if %leap% equ 0 set dpm[2]=29
  if %day% gtr !dpm[%month%]! goto :invalidDate
  if %day% lss 1 goto :invalidDate
  if %year% lss 1000 goto :invalidDate
  if %year% gtr 2099 goto :invalidDate

  :: Atribuição da data à variável
  set finalDate=%DD%-%MM%-%YYYY%
  set finalDateSQL=%YYYY%-%MM%-%DD%

  :: Encaminhamento para função de confirmação
  goto :confirmStage
  
  :: Função de erro no formato da data
  :invalidDate
    cls
    for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
      set "DEL=%%a"
    )
    call :colorEcho cf "Formato de data incorreto! Tente novamente... "
    echo.
    echo Data inicial: %initialDate%
    goto :getFinalDate

:: Função de confirmação das entradas de data
:confirmStage
  cls
  echo Codigo da empresa: %companyId%
  echo Data inicial: %initialDate%
  echo Data final: %finalDate%

  echo.

  set /p confirmation=Esta correto? (S/n): 
  if "%confirmation%" == "n" (
    cls
    set confirmation=''
    goto getInitialDate
  )

echo.

:: Verifica e existência do Firebird
if EXIST "C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe" (
  goto :firebird
) else (
  goto :firebird32
)

:firebird32
  if EXIST "C:\Program Files (x86)\Firebird\Firebird_2_5\bin\isql.exe" (
    goto :firebird
) else (
  echo Instalacao do firebird NAO encontrada!
  echo Verifique se firebird foi instalado corretamente e tente novamente...
  :: Atraso de 5 segundos antes de fechar o programa
  ping 127.0.0.1 -n 5 > nul
  :: Comando para fechar a janela do cmd
  exit
)

:firebird
  set isql="C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe"
  set dbPath="C:\Sinco\Integrado\FACILITE.FDB"
  set file="%cd%\query.sql"

  echo DELETE FROM GONDOLA;> %file%

  %isql% %dbPath% -user sysdba -password masterkey -i %file% -q

  echo INSERT INTO GONDOLA (GOND_PRODUTO, GOND_BARRAS, GOND_NUMERO, GOND_SEQUENCIA, GOND_DESCRICAO, GOND_VALOR, GOND_NOMEREDUZIDO, GOND_STATUS, GOND_MARCA, GOND_CODIGOFABRICA, GOND_GRADE, GOND_COR, GOND_APRESENTACAO, GOND_VALORATACADO, GOND_VALIDADE) select PRO_CODIGO, PRO_CODIGOBARRA, PRO_ESTOQUEATUAL, 1, PRO_DESCRICAO, 1, PRO_NOMEREDUZIDO, 'Q', '', '', NULL, NULL, 'AP', 1000, NULL from PRODUTO WHERE ((PRO_INATIVO = 'False') or (PRO_INATIVO is null)) AND PRO_EMPRESA = '%companyId%' AND PRO_ESTOQUEATUAL ^> 0 and PRO_DATACADASTRO BETWEEN '%initialDateSQL%' AND '%finalDateSQL%';>%file%

  %isql% %dbPath% -user sysdba -password masterkey -i %file% -q

  del %file%

echo.

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
    set "DEL=%%a"
)
call :colorEcho a0 "Concluido com sucesso!"

echo.

:: Atraso de 5 segundos antes de fechar o programa
ping 127.0.0.1 -n 5 > nul

:: Comando para fechar a janela do cmd
exit

:: Função para alterar cores
:colorEcho
  echo off
  <nul set /p ".=%DEL%" > "%~2"
  findstr /v /a:%1 /R "^$" "%~2" nul
  del "%~2" > nul 2>&1i
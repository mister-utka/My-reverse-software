include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include Gdi32.inc
include masm32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib Gdi32.lib
includelib masm32.lib

WinMain				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc				PROTO :DWORD,:DWORD,:DWORD,:DWORD

IDD_DIALOG				 		equ 1000
IDC_EDT_GET_NAME_PROC	 		equ 1001
IDC_BTN_FREEZ			 		equ 1002
IDC_BTN_RUN				 		equ 1006
IDC_EDT_SEND_INFO_PROC	 		equ 1003
IDC_TEXT_INFO_GET_PROC	 		equ 1005
IDC_TEXT_INFO_FREZ_PROC  		equ 1007
IDC_EDT_SEARCH_FREQUENCY		equ 1008
IDC_TEXT_SEARCH_FREQUENCY		equ 1011
IDC_EDT_DELAY_AFTER_DETECTION 	equ 1009
IDC_TEXT_DELAY_AFTER_DETECTION	equ 1010


IDM_MENU						equ 10000
IDM_FILE_EXIT					equ 10001
IDM_HELP_ABOUT					equ 10101

.const
ClassName			 db 'DLGCLASS',0
AppName				 db 'StopChildProc',0
AboutMsg			 db 'MASM32 RadASM Dialog as main',13,10,'Copyright © MASM32 2001',0

.data
buffer				 db 16384 dup(0)			;для вывода дерева замороженных процессов процессов
StrProcID            db 512 dup(0)				;для перевода PID процесса в строку
formatPID 			 db "%d",0					;форматирование
pszFntName			 db "Segoe UI Variable", 0	;имя шрифта
flagThreadSearchProc db 1						;1 - поток работает, 0 - поток завершен
pszEnter			 db 0Dh,0Ah,0
pszTab				 db 09h,0
pszSpace			 db 20h,0
pszZero				 db '0',0

SearchFrequency		db 9 dup(0)
DelayAfterDetection db 9 dup(0)

;Строки ошибок
pszError				db 'Error',0
pszSearchFrequencyErr db 'The entered parameter is not a number', 0
pszLenErr				db 'The entered parameter is too long',0

.data?
hFont			     HANDLE ?					;хендл шрифта
hInstance			 dd ?
CommandLine			 dd ?
hWnd				 dd ?

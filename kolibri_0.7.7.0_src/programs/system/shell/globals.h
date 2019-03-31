
#define FALSE 0
#define TRUE 1

#define SHELL_VERSION "0.4.2"

extern char	PATH[256];
extern char	PARAM[256];

char		title[64];
char		cur_dir[256];

/// ===========================================================

char		*ALIASES = NULL;
unsigned	ALIAS_NUM = 0;

/// ===========================================================

#define CMD_HISTORY_NUM 5

char		CMD[256];
char		CMD_HISTORY[CMD_HISTORY_NUM][256];
char		CMD_NUM;

unsigned	CMD_POS;

/// ===========================================================

char script_sign[] = {"#SHS"};

/// ===========================================================

const NUM_OF_CMD = 20;

typedef struct
{
	const char* name;
	const char* help;
	const void* handler;
	int numargs;
} command_t;

void cmd_about(void);
void cmd_alias(char arg[]);
int cmd_cd(char dir[]);
void cmd_clear(void);
void cmd_date(void);
void cmd_echo(char text[]);
void cmd_exit(void);
void cmd_free(void);
int cmd_help(char cmd[]);
int cmd_kill(char process[]);
int cmd_ls(char dir[]);
int cmd_mkdir(char dir[]);
int cmd_more(char file[]);
int cmd_ps(void);
void cmd_pwd(void);
void cmd_reboot(void);
int cmd_rm(char file[]);
int cmd_rmdir(char dir[]);
int cmd_touch(char file[]);
void cmd_ver(void);

const command_t COMMANDS[]=
{
	{"about", "  Displays information about the program\n\r", &cmd_about, 0},
	{"alias", "  Allows the user view the current aliases\n\r", &cmd_alias, 1},
	{"cd",    "  Changes directories\n\r", &cmd_cd, 1},
	{"clear", "  Clears the display\n\r", &cmd_clear, 0},
	{"date",  "  Returns the date and time\n\r", &cmd_date, 0},
	{"echo",  "  Echoes the data to the screen\n\r", &cmd_echo, -1},
	{"exit",  "  Exits program\n\r", &cmd_exit, 0},
	{"free",  "  Displays total, free and used memory\n\r", &cmd_free, 0},
	{"help",  "  Gives help\n\r", &cmd_help, 1},
	{"kill",  "  Stops a running process\n\r", &cmd_kill, 1},
	{"ls",    "  Lists the files in a directory\n\r", &cmd_ls, 1},
	{"mkdir", "  Makes directory\n\r", &cmd_mkdir, 1},
	{"more",  "  Displays a data file to the screen\n\r", &cmd_more, 1},
	{"ps",    "  Lists the current processes running\n\r", &cmd_ps, 0},
	{"pwd",   "  Displays the name of the working directory\n\r", &cmd_pwd, 0},
	{"reboot","  Reboots the computer\n\r", &cmd_reboot, 0},
	{"rm",    "  Removes files\n\r", &cmd_rm, 1},
	{"rmdir", "  Removes directories\n\r", &cmd_rmdir, 1},
	{"touch", "  Creates an empty file or updates the time/date stamp on a file\n\r", &cmd_touch, 1},
	{"ver",   "  Displays version\n\r", &cmd_ver, 0},
};

/// ===========================================================

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const mibase_1 = require("./mibase");
const vscode_debugadapter_1 = require("vscode-debugadapter");
const mi2_1 = require("./backend/mi2/mi2");
class GDBDebugSession extends mibase_1.MI2DebugSession {
    initializeRequest(response, args) {
        response.body.supportsGotoTargetsRequest = true;
        response.body.supportsHitConditionalBreakpoints = true;
        response.body.supportsConfigurationDoneRequest = true;
        response.body.supportsConditionalBreakpoints = true;
        response.body.supportsFunctionBreakpoints = true;
        response.body.supportsEvaluateForHovers = true;
        response.body.supportsSetVariable = true;
        response.body.supportsStepBack = true;
        this.sendResponse(response);
    }
    launchRequest(response, args) {
        this.miDebugger = new mi2_1.MI2(args.gdbpath || "gdb", ["-q", "--interpreter=mi2"], args.debugger_args, args.env);
        this.setPathSubstitutions(args.pathSubstitutions);
        this.initDebugger();
        this.quit = false;
        this.attached = false;
        this.needContinue = false;
        this.isSSH = false;
        this.started = false;
        this.crashed = false;
        this.debugReady = false;
        this.setValuesFormattingMode(args.valuesFormatting);
        this.miDebugger.printCalls = !!args.printCalls;
        this.miDebugger.debugOutput = !!args.showDevDebugOutput;
        if (args.ssh !== undefined) {
            if (args.ssh.forwardX11 === undefined)
                args.ssh.forwardX11 = true;
            if (args.ssh.port === undefined)
                args.ssh.port = 22;
            if (args.ssh.x11port === undefined)
                args.ssh.x11port = 6000;
            if (args.ssh.x11host === undefined)
                args.ssh.x11host = "localhost";
            if (args.ssh.remotex11screen === undefined)
                args.ssh.remotex11screen = 0;
            this.isSSH = true;
            this.trimCWD = args.cwd.replace(/\\/g, "/");
            this.switchCWD = args.ssh.cwd;
            this.miDebugger.ssh(args.ssh, args.ssh.cwd, args.target, args.arguments, args.terminal, false).then(() => {
                if (args.autorun)
                    args.autorun.forEach(command => {
                        this.miDebugger.sendUserInput(command);
                    });
                setTimeout(() => {
                    this.miDebugger.emit("ui-break-done");
                }, 50);
                this.sendResponse(response);
                this.miDebugger.start().then(() => {
                    this.started = true;
                    if (this.crashed)
                        this.handlePause(undefined);
                }, err => {
                    this.sendErrorResponse(response, 100, `Failed to start MI Debugger: ${err.toString()}`);
                });
            }, err => {
                this.sendErrorResponse(response, 102, `Failed to SSH: ${err.toString()}`);
            });
        }
        else {
            this.miDebugger.load(args.cwd, args.target, args.arguments, args.terminal).then(() => {
                if (args.autorun)
                    args.autorun.forEach(command => {
                        this.miDebugger.sendUserInput(command);
                    });
                setTimeout(() => {
                    this.miDebugger.emit("ui-break-done");
                }, 50);
                this.sendResponse(response);
                this.miDebugger.start().then(() => {
                    this.started = true;
                    if (this.crashed)
                        this.handlePause(undefined);
                }, err => {
                    this.sendErrorResponse(response, 100, `Failed to Start MI Debugger: ${err.toString()}`);
                });
            }, err => {
                this.sendErrorResponse(response, 103, `Failed to load MI Debugger: ${err.toString()}`);
            });
        }
    }
    attachRequest(response, args) {
        this.miDebugger = new mi2_1.MI2(args.gdbpath || "gdb", ["-q", "--interpreter=mi2"], args.debugger_args, args.env);
        this.setPathSubstitutions(args.pathSubstitutions);
        this.initDebugger();
        this.quit = false;
        this.attached = !args.remote;
        this.needContinue = true;
        this.isSSH = false;
        this.debugReady = false;
        this.setValuesFormattingMode(args.valuesFormatting);
        this.miDebugger.printCalls = !!args.printCalls;
        this.miDebugger.debugOutput = !!args.showDevDebugOutput;
        if (args.ssh !== undefined) {
            if (args.ssh.forwardX11 === undefined)
                args.ssh.forwardX11 = true;
            if (args.ssh.port === undefined)
                args.ssh.port = 22;
            if (args.ssh.x11port === undefined)
                args.ssh.x11port = 6000;
            if (args.ssh.x11host === undefined)
                args.ssh.x11host = "localhost";
            if (args.ssh.remotex11screen === undefined)
                args.ssh.remotex11screen = 0;
            this.isSSH = true;
            this.trimCWD = args.cwd.replace(/\\/g, "/");
            this.switchCWD = args.ssh.cwd;
            this.miDebugger.ssh(args.ssh, args.ssh.cwd, args.target, "", undefined, true).then(() => {
                if (args.autorun)
                    args.autorun.forEach(command => {
                        this.miDebugger.sendUserInput(command);
                    });
                setTimeout(() => {
                    this.miDebugger.emit("ui-break-done");
                }, 50);
                this.sendResponse(response);
            }, err => {
                this.sendErrorResponse(response, 102, `Failed to SSH: ${err.toString()}`);
            });
        }
        else {
            if (args.remote) {
                this.miDebugger.connect(args.cwd, args.executable, args.target).then(() => {
                    if (args.autorun)
                        args.autorun.forEach(command => {
                            this.miDebugger.sendUserInput(command);
                        });
                    this.sendResponse(response);
                }, err => {
                    this.sendErrorResponse(response, 102, `Failed to attach: ${err.toString()}`);
                });
            }
            else {
                this.miDebugger.attach(args.cwd, args.executable, args.target).then(() => {
                    if (args.autorun)
                        args.autorun.forEach(command => {
                            this.miDebugger.sendUserInput(command);
                        });
                    this.sendResponse(response);
                }, err => {
                    this.sendErrorResponse(response, 101, `Failed to attach: ${err.toString()}`);
                });
            }
        }
    }
    // Add extra commands for source file path substitution in GDB-specific syntax
    setPathSubstitutions(substitutions) {
        if (substitutions) {
            Object.keys(substitutions).forEach(source => {
                this.miDebugger.extraCommands.push("gdb-set substitute-path " + source + " " + substitutions[source]);
            });
        }
    }
}
vscode_debugadapter_1.DebugSession.run(GDBDebugSession);
//# sourceMappingURL=gdb.js.map
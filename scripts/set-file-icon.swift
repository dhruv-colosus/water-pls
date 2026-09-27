import AppKit

guard CommandLine.arguments.count == 3,
      let image = NSImage(contentsOfFile: CommandLine.arguments[1]) else {
    fputs("Usage: swift set-file-icon.swift IMAGE FILE\n", stderr)
    exit(1)
}
let path = URL(fileURLWithPath: CommandLine.arguments[2]).path
guard NSWorkspace.shared.setIcon(image, forFile: path, options: []) else {
    fputs("Could not set Finder icon for \(path)\n", stderr)
    exit(1)
}

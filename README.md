# Directory Size Analyzer

This utility, written in the Ring programming language, provides a comprehensive analysis of directory and file sizes. It offers detailed reporting options and can handle both Windows and Unix-like file systems.

## Features

- Calculate the size of individual files or entire directories
- Provide detailed listings of directory contents with sizes
- Sort entries by size (optional)
- Cross-platform compatibility (Windows and Unix-like systems)
- Performance timing for size calculations

## Usage

```
Usage: DirSize Path [-details [-sort]]
```

- `Path`: The file or directory path to analyze
- `-details`: (Optional) Provide a detailed listing of directory contents
- `-sort`: (Optional) Sort the detailed listing by size (largest first)

## Examples

1. Get the size of a directory:
   ```
   DirSize C:\Users\Username\Documents
   ```

2. Get a detailed listing of a directory:
   ```
   DirSize C:\Users\Username\Documents -details
   ```

3. Get a sorted detailed listing of a directory:
   ```
   DirSize C:\Users\Username\Documents -details -sort
   ```

## Output

The program provides the following information:

- Total size of the file or directory
- Execution time
- (If -details is used) A list of all entries in the directory with their sizes
- (If -sort is used) The list is sorted by size in descending order

## Requirements

- MonoRing distribution of the Ring programming language (https://github.com/idrassi/MonoRing/releases)
- 

## Installation

1. Ensure you have Ring installed on your system.
2. Clone this repository or download the `DirSize.ring` file.
3. Run the program using the Ring interpreter:
   ```
   ring DirSize.ring [arguments]
   ```
4. To create a standalone executable, type the following command:
   ```
   ring2exe -static DirSize.ring
   ```
 
## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](https://github.com/idrassi/DirSize/issues) if you want to contribute.

## License

[MIT License](LICENSE)

## Author

[Mounir IDRASSI]

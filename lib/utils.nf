import java.nio.file.*

/**
 * Constructs a search path for FASTQ files based on the given input path,
 * illuminaSuffixes, and fastq_exts.
 *
 * @param input           The input path as a String.
 * @param illuminaSuffixes A list of illumina suffixes to search for, e.g., ["_R1", "_R2"].
 * @param fastq_exts      A list of FASTQ file extensions to search for, e.g., [".fastq", ".fq"].
 * @return                A list of search paths for FASTQ files.
 */
def makeFastqSearchPath(input, illuminaSuffixes, fastq_exts) {
    def fastq_searchpath = []
    for (item in illuminaSuffixes) {
        for (fq_ext in fastq_exts) {
            fastq_searchpath.add(input.toString() + '/**' + item.toString() + fq_ext.toString())
        }
    }
    return fastq_searchpath
}

def isRemoteFile(String path) {
    // Check if the path starts with either "s3" or "https" and ends with ".csv"
    return path.startsWith("s3") || path.startsWith("https") && path.endsWith(".csv")
}

def removeDoubleQuotes(String input) {
    return input.replaceAll('"', '')
}

/**
 * Determines whether the given path is a file ending with the ".csv" extension or a folder.
 *
 * @param path The path to be checked as a String.
 * @return     The type of the path: "csv" if it's a file ending with ".csv", "folder" if it's a folder.
 */
def isFileOrFolder(String path) {
    // Convert the path to a File object
    def file = Paths.get(path).toFile()

    if ((file.isFile() && file.getName().endsWith(".csv")) || isRemoteFile(path)) {
        // If the path is a file and ends with ".csv", return "csv"
        return "csv"
    } else if (file.isDirectory()) {
        // If the path is a directory, return "folder"
        return "folder"
    } else {
        // If the path is neither a file ending with ".csv" nor a folder, print an error message and exit the program
        println("The path is neither a file ending with the '.csv' extension nor a folder.")
        System.exit(1)
    }
}




/**
 * Creates an input channel based on the given input path.
 *
 * @param input The input path as a String.
 * @return An input channel for further processing.
 */
def make_input(input) {
    // Determine the type of input (csv or folder)
    input_type = isFileOrFolder(input)

    if (input_type == "csv") {
        // Input is a csv file

        // Read the csv file and create a channel
        ch_input = Channel.fromPath(input)
                          .splitCsv(header: ['sample_id', 'R1', 'R2'], skip: 1)
                          .filter{it.R2 != '""'}
                          .map { row -> tuple(removeDoubleQuotes(row.sample_id), [removeDoubleQuotes(row.R1), removeDoubleQuotes(row.R2)])}
    } else if (input_type == "folder") {
        // Input is a folder

        // Generate search patterns for FASTQ files
        search_pattern = makeFastqSearchPath(input, params.illuminaSuffixes, params.fastq_exts)

        // Create a channel using the search patterns
        ch_input = Channel.fromFilePairs(search_pattern)
    }
    
    return ch_input
}

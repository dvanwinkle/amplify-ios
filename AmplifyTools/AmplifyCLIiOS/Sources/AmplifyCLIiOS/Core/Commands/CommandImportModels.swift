//
// Copyright Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

enum CommandImportModelsTasks {
    static func projectHasGeneratedModels(context: AmplifyCommandEnvironment,
                                          args: CommandImportModels.TaskArgs) -> AmplifyCommandTaskResult {
        let modelsPath = context.path(for: args.generatedModelsPath)
        if context.directoryExists(atPath: modelsPath) {
            return .success("Amplify models folder found at \(modelsPath)")
        }
        // try context.content(of: modelsPath).isEmpty

        let recoveryMsg = "We couldn't find any generated models at \(modelsPath). Please run amplify codegen models."
        return .failure(
            AmplifyCommandError(
                .folderNotFound,
                error: nil,
                recoverySuggestion: recoveryMsg))
    }

    static func addGeneratedModelsToProject(context: AmplifyCommandEnvironment,
                                            args: CommandImportModels.TaskArgs) -> AmplifyCommandTaskResult {
        let models = context.glob(pattern: "\(args.generatedModelsPath)/*.swift").map {
            context.createXcodeFile(withPath: $0, ofType: .source)
        }

        do {
            try context.addFilesToXcodeProject(projectPath: context.basePath, files: models, toGroup: args.modelsGroup)
            return .success("Successfully added models \(models) to \(args.modelsGroup) group.")
        } catch {
            return .failure(AmplifyCommandError(.xcodeProject, error: error))
        }
    }
}

struct CommandImportModels: AmplifyCommand {
    struct CommandImportModelsArgs {
        let modelsGroup = "AmplifyModels"
        let generatedModelsPath = "amplify/generated/models"
    }

    typealias TaskArgs = CommandImportModelsArgs

    static var description = "Import Amplify models"

    var taskArgs = CommandImportModelsArgs()

    var tasks: [AmplifyCommandTask<CommandImportModelsArgs>] = [
        .run(CommandImportModelsTasks.projectHasGeneratedModels),
        .run(CommandImportModelsTasks.addGeneratedModelsToProject)
    ]

    func onFailure() {
    }
}

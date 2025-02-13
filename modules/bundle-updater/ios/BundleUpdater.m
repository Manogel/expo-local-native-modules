#import "BundleUpdater.h"

static NSString *const kBundleFileName = @"index.ios.custom.bundle";
static NSString *const kAppVersionKey = @"BundleUpdater_appVersion";
static NSString *const kBundleVersionKey = @"BundleUpdater_bundleVersion";

@implementation BundleUpdater

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

- (NSString *)customBundlePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    return [documentsPath stringByAppendingPathComponent:kBundleFileName];
}

- (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"";
}

- (NSDictionary *)getPreferences {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appVersion = [defaults stringForKey:kAppVersionKey] ?: @"";
    NSString *bundleVersion = [defaults stringForKey:kBundleVersionKey] ?: @"";
    return @{@"appVersion": appVersion, @"bundleVersion": bundleVersion};
}

- (void)savePreferencesWithAppVersion:(NSString *)appVersion bundleVersion:(NSString *)bundleVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:appVersion forKey:kAppVersionKey];
    [defaults setObject:bundleVersion forKey:kBundleVersionKey];
    [defaults synchronize];
}

- (void)clearPreferences {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kAppVersionKey];
    [defaults removeObjectForKey:kBundleVersionKey];
    [defaults synchronize];
}

- (void)clearBundle {
    NSLog(@"[BundleUpdater] Iniciando limpeza do bundle");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *bundlePath = [self customBundlePath];

    if ([fileManager fileExistsAtPath:bundlePath]) {
        NSLog(@"[BundleUpdater] Removendo bundle existente em: %@", bundlePath);
        [fileManager removeItemAtPath:bundlePath error:&error];
        if (error) {
            NSLog(@"[BundleUpdater] Erro ao remover bundle: %@", error);
        }
    }
    NSLog(@"[BundleUpdater] Limpando preferências");
    [self clearPreferences];
    NSLog(@"[BundleUpdater] Bundle limpo com sucesso");
}

- (NSString *)getBundlePath:(void (^)(NSString *))resolve rejecter:(void (^)(NSString *, NSString *, NSError *))reject {
    NSString *bundlePath = [self customBundlePath];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath];

    NSDictionary *result = @{
        @"isExists": @(exists),
        @"path": bundlePath
    };

    return [self jsonStringFromDictionary:result];
}

- (NSString *)getBundleInfo {
    NSLog(@"[BundleUpdater] Obtendo informações do bundle");
    NSDictionary *prefs = [self getPreferences];
    NSString *bundlePath = [self customBundlePath];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath];

    NSString *currentAppVersion = [self getAppVersion];
    NSLog(@"[BundleUpdater] Versão atual do app: %@", currentAppVersion);
    NSLog(@"[BundleUpdater] Versão do app no bundle: %@", prefs[@"appVersion"]);
    NSLog(@"[BundleUpdater] Versão do bundle: %@", prefs[@"bundleVersion"]);
    NSLog(@"[BundleUpdater] Bundle existe: %@", exists ? @"Sim" : @"Não");
    NSLog(@"[BundleUpdater] Caminho do bundle: %@", bundlePath);

    NSDictionary *result = @{
        @"currentAppVersion": [self getAppVersion],
        @"bundleAppVersion": prefs[@"appVersion"],
        @"bundleVersion": prefs[@"bundleVersion"],
        @"haveBundleSaved": @(exists),
        @"bundlePath": bundlePath
    };

    return [self jsonStringFromDictionary:result];
}

- (void)applyBundle:(NSString *)bundlePath
       bundleVersion:(NSString *)bundleVersion
           resolver:(void (^)(NSString *))resolve
           rejecter:(void (^)(NSString *, NSString *, NSError *))reject {
    NSLog(@"[BundleUpdater] Iniciando aplicação do bundle");
    NSLog(@"[BundleUpdater] Bundle origem: %@", bundlePath);
    NSLog(@"[BundleUpdater] Versão do bundle: %@", bundleVersion);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *customPath = [self customBundlePath];
    NSError *error = nil;

    if ([fileManager fileExistsAtPath:customPath]) {
        NSLog(@"[BundleUpdater] Removendo bundle existente");
        [fileManager removeItemAtPath:customPath error:&error];
        if (error) {
            NSLog(@"[BundleUpdater] Erro ao remover bundle existente: %@", error);
            reject(@"ERROR", @"Failed to remove existing bundle", error);
            return;
        }
    }

    NSLog(@"[BundleUpdater] Copiando novo bundle");
    [fileManager copyItemAtPath:bundlePath toPath:customPath error:&error];
    if (error) {
        NSLog(@"[BundleUpdater] Erro ao copiar bundle: %@", error);
        reject(@"ERROR", @"Failed to copy bundle", error);
        return;
    }

    NSString *appVersion = [self getAppVersion];
    NSLog(@"[BundleUpdater] Salvando preferências - App version: %@, Bundle version: %@", appVersion, bundleVersion);
    [self savePreferencesWithAppVersion:appVersion bundleVersion:bundleVersion];
    NSLog(@"[BundleUpdater] Bundle aplicado com sucesso em: %@", customPath);
    resolve(customPath);
}

+ (NSURL *)getBundleURL {
    NSLog(@"[BundleUpdater] Iniciando getBundleURL");
    BundleUpdater *manager = [[BundleUpdater alloc] init];
    if ([manager validateBundle]) {
        NSString *bundlePath = [manager customBundlePath];
        NSLog(@"[BundleUpdater] Bundle válido encontrado, retornando URL: %@", bundlePath);
        return [NSURL fileURLWithPath:bundlePath];
    }
    NSLog(@"[BundleUpdater] Nenhum bundle válido encontrado, retornando nil");
    return nil;
}

- (BOOL)validateBundle {
    NSLog(@"[BundleUpdater] Iniciando validação do bundle");
    NSString *currentAppVersion = [self getAppVersion];
    NSDictionary *prefs = [self getPreferences];
    NSString *savedAppVersion = prefs[@"appVersion"];
    NSString *bundlePath = [self customBundlePath];

    NSLog(@"[BundleUpdater] Versão atual do app: %@", currentAppVersion);
    NSLog(@"[BundleUpdater] Versão salva do app: %@", savedAppVersion);
    NSLog(@"[BundleUpdater] Bundle existe: %@", [[NSFileManager defaultManager] fileExistsAtPath:bundlePath] ? @"Sim" : @"Não");

    if ([savedAppVersion isEqualToString:currentAppVersion] &&
        [[NSFileManager defaultManager] fileExistsAtPath:bundlePath]) {
        NSLog(@"[BundleUpdater] Bundle válido encontrado");
        return YES;
    }

    if ([prefs[@"bundleVersion"] length] > 0 ||
        [[NSFileManager defaultManager] fileExistsAtPath:bundlePath]) {
        NSLog(@"[BundleUpdater] Bundle inválido, iniciando limpeza");
        [self clearBundle];
    }

    NSLog(@"[BundleUpdater] Bundle inválido");
    return NO;
}

- (NSString *)jsonStringFromDictionary:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!jsonData) {
        return @"{}";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end 

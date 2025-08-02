export interface ServiceGeneratorSchema {
    name: string;
    language?: 'python' | 'node';
    database?: boolean;
}

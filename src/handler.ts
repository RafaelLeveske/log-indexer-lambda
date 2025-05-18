import { CloudWatchLogsEvent } from 'aws-lambda';
import zlib from 'zlib';
import { Client } from '@opensearch-project/opensearch';
import { awsGetSigV4Signer } from './utils/sigv4-signer';

let client: Client;

export const indexLogs = async (event: CloudWatchLogsEvent) => {
  if (!client) {
    const { Connection, Transport } = await awsGetSigV4Signer({
      region: process.env.AWS_REGION || 'us-east-1',
      service: 'es',
    });

    client = new Client({
      node: process.env.OPENSEARCH_ENDPOINT!,
      Connection,
      Transport, // ✅ adiciona isso explicitamente
    });
  }

  const payload = Buffer.from(event.awslogs.data, 'base64');
  const decompressed = zlib.gunzipSync(payload).toString('utf-8');
  const parsed = JSON.parse(decompressed);

  const logEvents = parsed.logEvents || [];

  for (const log of logEvents) {
    const body = {
      timestamp: log.timestamp,
      message: log.message,
      logGroup: parsed.logGroup,
      logStream: parsed.logStream,
    };

  try {
    await client.transport.request({
      method: 'POST',
      path: `/${process.env.OPENSEARCH_INDEX || 'application-logs'}/_doc`,
      body,
    });
    console.log('✅ Log indexado com sucesso');
  } catch (err) {
    console.error('❌ Erro ao indexar log:', err);
  }
}

  return { statusCode: 200, body: 'OK' };
};

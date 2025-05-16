import { AwsSigv4Signer } from '@opensearch-project/opensearch/aws';
import { defaultProvider } from "@aws-sdk/credential-provider-node";

export const awsGetSigV4Signer = async ({
  region,
  service,
}: {
  region: string;
  service: 'es' | 'aoss';
}) => {
  const getCredentials = defaultProvider();
  const signer = AwsSigv4Signer({
    region,
    service,
    getCredentials,
  });

  return {
    Connection: signer.Connection,
  };
};

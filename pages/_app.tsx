import type { AppProps } from "next/app";
import { ChainId, ThirdwebProvider } from "@thirdweb-dev/react";
import "../styles/globals.css";

// This is the chainId your dApp will work on.
// const activeChainId = ChainId.Polygon;
const activeChain = "mumbai";
const activeClientId = "507db7365d0ff5a6d7057de30203aa7f";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    // <ThirdwebProvider desiredChainId={activeChainId}>
    <ThirdwebProvider
      activeChain={activeChain}
      // clientId={process.env.NEXT_PUBLIC_TEMPLATE_CLIENT_ID}
      clientId={activeClientId}
    >
      <Component {...pageProps} /> 
    </ThirdwebProvider>
  );
}

export default MyApp;
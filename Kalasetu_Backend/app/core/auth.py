import base64
import jwt
from fastapi import Header, HTTPException
from app.core.config import SUPABASE_JWT_SECRET


PROJECT_REF = "xdhnohznazckfqssskhw"
JWKS_URL = f"https://{PROJECT_REF}.supabase.co/auth/v1/.well-known/jwks.json"
jwks_client = jwt.PyJWKClient(JWKS_URL)


def verify_user(authorization: str = Header(...)) -> str:
    """Decode a Supabase JWT and return the user_id (sub claim).
    Raises 401 if the token is missing, invalid, or expired."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or malformed Authorization header")
    
    token = authorization.removeprefix("Bearer ").strip()
    
    try:
        header = jwt.get_unverified_header(token)
        token_alg = header.get("alg", "HS256")
    except Exception as e:
        print(f"[Auth Error] Failed to read JWT header: {e}")
        token_alg = "HS256"

    allowed_algs = list(set([token_alg, "HS256", "HS384", "HS512", "RS256", "ES256", "EdDSA", "PS256"]))

    # 1. Asymmetric algorithms (ES256, RS256, etc.) using Supabase JWKS
    if token_alg.startswith("ES") or token_alg.startswith("RS") or token_alg.startswith("PS"):
        try:
            signing_key = jwks_client.get_signing_key_from_jwt(token)
            payload = jwt.decode(
                token,
                signing_key.key,
                algorithms=allowed_algs,
                options={"verify_aud": False},
            )
            sub = payload.get("sub")
            if not sub:
                raise HTTPException(status_code=401, detail="Token missing user 'sub' claim")
            return sub
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="Token expired")
        except Exception as e:
            print(f"[Auth Error] JWKS verification failed for alg={token_alg}: {e}")

    # 2. Symmetric algorithms (HS256) using JWT Secret
    secrets_to_try = [SUPABASE_JWT_SECRET]
    try:
        secrets_to_try.append(base64.b64decode(SUPABASE_JWT_SECRET))
    except Exception:
        pass

    last_error = None
    for secret in secrets_to_try:
        try:
            payload = jwt.decode(
                token,
                secret,
                algorithms=allowed_algs,
                options={"verify_aud": False},
            )
            sub = payload.get("sub")
            if not sub:
                raise HTTPException(status_code=401, detail="Token missing user 'sub' claim")
            return sub  # the user UUID
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="Token expired")
        except jwt.PyJWTError as e:
            last_error = e

    print(f"[Auth Error] Failed to decode token (alg={token_alg}): {last_error}")
    raise HTTPException(status_code=401, detail=f"Invalid token: {last_error}")

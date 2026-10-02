export interface JwtPayload {
  sub: string;
  sid: string;
  accountType: string;
  memberId?: string | null;
  roles: string[];
}

export interface AuthUser {
  id: string;
  email: string | null;
  loginId: string | null;
  firstName: string;
  lastName: string;
  phone: string | null;
  status: string;
  accountType: string;
  memberId: string | null;
  roles: string[];
  permissions: string[];
}